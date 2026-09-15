import pandas as pd
from io import BytesIO
from django.http import HttpResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from datetime import datetime, timedelta
from django.db.models import Q

from .models import Funsonariu, Presensa, KonfigurasaunSistema, PediduLisensa, LoronFeriadu, ShiftServisu, PediduLembur
from .serializers import FunsonariuSerializer, PresensaSerializer, PresensaInputSerializer, PediduLisensaSerializer, KonfigurasaunSistemaSerializer, PediduLemburSerializer

# Koordinat fatin servisu (Ezemplu: Kantor iha Dili)
OFFICE_LAT = -8.5568
OFFICE_LNG = 125.5603

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

def get_konfigurasaun():
    """Hau ka foti default KonfigurasaunSistema."""
    konfigurasaun, created = KonfigurasaunSistema.objects.get_or_create(id=1)
    return konfigurasaun

from rest_framework.permissions import IsAuthenticated, AllowAny

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        nre = request.data.get('nre')
        password = request.data.get('password')
        device_id = request.data.get('device_id')

        if not nre or not password:
            return Response({'error': 'NRE ho Password tenke priense'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            funsonariu = Funsonariu.objects.get(nre=nre)
        except Funsonariu.DoesNotExist:
            return Response({'error': 'NRE la hetan'}, status=status.HTTP_404_NOT_FOUND)

        if not funsonariu.check_password(password):
            return Response({'error': 'Password sala'}, status=status.HTTP_401_UNAUTHORIZED)

        if not funsonariu.is_active:
            return Response({'error': 'Kontu nee la aktivu, favor kontaktu Admin'}, status=status.HTTP_403_FORBIDDEN)

        # --- Device Binding Check ---
        if device_id:
            if not funsonariu.device_id:
                # Lock device id
                funsonariu.device_id = device_id
                funsonariu.save(update_fields=['device_id'])
            elif funsonariu.device_id != device_id:
                return Response({'error': 'Device ID la match! Titip absen la permite.'}, status=status.HTTP_403_FORBIDDEN)
        # ----------------------------

        tokens = get_tokens_for_user(funsonariu)
        return Response({
            'tokens': tokens,
            'naran_funsonariu': funsonariu.naran,
            'nre': funsonariu.nre,
            'kargu': funsonariu.kargu,
            'unidade_traballu': funsonariu.unidade_traballu,
            'foto': funsonariu.foto.url if funsonariu.foto else None,
            'kuota_cuti_anual': funsonariu.kuota_cuti_anual,
        })

class AbsensiView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = PresensaInputSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        lat = serializer.validated_data['latitude']
        lng = serializer.validated_data['longitude']
        dist = serializer.validated_data['distansia_metru']
        tipu = serializer.validated_data['tipu_absensi']
        
        konf = get_konfigurasaun()
        now = timezone.now()
        today = now.date()

        # 1. CEK RAIO GPS
        if dist > konf.limite_raio_metru:
            return Response({'error': f'Ita boot iha liur husi raio servisu ({int(dist)}m). Favor besik ba kantór!'}, status=status.HTTP_400_BAD_REQUEST)

        # --- Multiple Shifts Support ---
        shift = request.user.shift
        oras_tama_remata = shift.oras_tama_remata if shift else konf.oras_tama_remata
        oras_sai_lokraik = shift.oras_sai_lokraik if shift else konf.oras_sai_lokraik
        # -------------------------------

        # 2. PROSESU PRESENSA
        presensa = Presensa.objects.filter(funsonariu=request.user, tempu_tama__date=today).first()

        if tipu == 'tama':
            if presensa:
                return Response({'error': 'Ita boot halo ona presensa tama dadersan nian ohin.'}, status=status.HTTP_400_BAD_REQUEST)
            
            # Cek oráriu tama
            current_time = now.time()
            res_status = 'prezente'
            if current_time > oras_tama_remata:
                res_status = 'tardiu'
            
            presensa = Presensa.objects.create(
                funsonariu=request.user,
                latitude=lat,
                longitude=lng,
                distansia_metru=dist,
                status=res_status
            )
            return Response({'message': f'Presensa tama susesu! (Estadu: {res_status})'})

        elif tipu == 'deskansa':
            if not presensa:
                return Response({'error': 'Ita boot seidauk presensa tama dadersan.'}, status=status.HTTP_400_BAD_REQUEST)
            if presensa.tempu_sai_deskansa:
                return Response({'error': 'Ita boot halo ona presensa deskansa.'}, status=status.HTTP_400_BAD_REQUEST)
            
            presensa.tempu_sai_deskansa = now
            presensa.save()
            return Response({'message': 'Presensa deskansa susesu!'})

        elif tipu == 'tama_lokraik':
            if not presensa:
                return Response({'error': 'Ita boot seidauk presensa tama dadersan.'}, status=status.HTTP_400_BAD_REQUEST)
            if not presensa.tempu_sai_deskansa:
                return Response({'error': 'Ita boot seidauk presensa deskansa.'}, status=status.HTTP_400_BAD_REQUEST)
            if presensa.tempu_tama_lokraik:
                return Response({'error': 'Ita boot halo ona presensa tama fali lokraik.'}, status=status.HTTP_400_BAD_REQUEST)
            
            presensa.tempu_tama_lokraik = now
            presensa.save()
            return Response({'message': 'Presensa tama lokraik susesu!'})

        elif tipu == 'sai':
            if not presensa:
                return Response({'error': 'Ita boot seidauk presensa tama dadersan.'}, status=status.HTTP_400_BAD_REQUEST)
            if presensa.tempu_sai:
                return Response({'error': 'Ita boot halo ona presensa fila lokraik.'}, status=status.HTTP_400_BAD_REQUEST)
            
            presensa.tempu_sai = now
            
            # Hatama Lembur se liu oráriu
            if now.time() > oras_sai_lokraik:
                finish_dt = timezone.make_aware(datetime.combine(today, oras_sai_lokraik))
                diff = now - finish_dt
                presensa.durasaun_horas_ekstra = round(diff.total_seconds() / 3600, 1)
                if presensa.durasaun_horas_ekstra > 0.5:
                    presensa.komentariu += f" [Horas Ekstra {presensa.durasaun_horas_ekstra} jam]"

            presensa.save()
            return Response({'message': 'Presensa fila lokraik susesu! Obrigadu.'})

        return Response({'error': 'Tipu presensa la hatene'}, status=status.HTTP_400_BAD_REQUEST)

class StatusHariIniView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = timezone.now().date()
        presensa = Presensa.objects.filter(funsonariu=request.user, tempu_tama__date=today).first()
        
        data = {
            'tama_ona': presensa is not None,
            'deskansa_ona': presensa.tempu_sai_deskansa is not None if presensa else False,
            'tama_lokraik_ona': presensa.tempu_tama_lokraik is not None if presensa else False,
            'sai_ona': presensa.tempu_sai is not None if presensa else False,
            'estadu': presensa.status if presensa else None,
            'detail': PresensaSerializer(presensa).data if presensa else None
        }
        return Response(data)

class RiwayatAbsensiView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        month = request.query_params.get('bulan', timezone.now().month)
        year = request.query_params.get('tahun', timezone.now().year)
        
        queryset = Presensa.objects.filter(funsonariu=request.user, tempu_tama__year=year, tempu_tama__month=month).order_by('-tempu_tama')
        serializer = PresensaSerializer(queryset, many=True)
        return Response(serializer.data)

class UnduhExcelView(APIView):
    def get(self, request):
        presensa_qs = Presensa.objects.all().select_related('funsonariu')
        data = []
        for p in presensa_qs:
            data.append({
                'NRE': p.funsonariu.nre,
                'Naran': p.funsonariu.naran,
                'Departamentu': p.funsonariu.unidade_traballu,
                'Data': p.tempu_tama.strftime('%Y-%m-%d'),
                'Tama': p.tempu_tama.strftime('%H:%M:%S'),
                'Deskansa': p.tempu_sai_deskansa.strftime('%H:%M:%S') if p.tempu_sai_deskansa else '-',
                'Tama Lokraik': p.tempu_tama_lokraik.strftime('%H:%M:%S') if p.tempu_tama_lokraik else '-',
                'Sai': p.tempu_sai.strftime('%H:%M:%S') if p.tempu_sai else '-',
                'Estadu': p.status,
                'Horas Ekstra (Jam)': p.durasaun_horas_ekstra,
                'Komentáriu': p.komentariu
            })
        
        df = pd.DataFrame(data)
        output = BytesIO()
        with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
            df.to_excel(writer, index=False, sheet_name='Presensa')
        
        response = HttpResponse(
            output.getvalue(),
            content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        response['Content-Disposition'] = f'attachment; filename=Relatoriu_Presensa_{timezone.now().date()}.xlsx'
        return response

class PengaturanSistemView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        konf = get_konfigurasaun()
        serializer = KonfigurasaunSistemaSerializer(konf)
        return Response(serializer.data)

class PengajuanIzinView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = PediduLisensaSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(funsonariu=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        queryset = PediduLisensa.objects.filter(funsonariu=request.user).order_by('-tempu_pedidu')
        serializer = PediduLisensaSerializer(queryset, many=True)
        return Response(serializer.data)


class MonitorLokalizasaunView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        """API hodi simu update lokalizasaun periodicamente."""
        from .models import ViolaLokalizasaun
        
        lat = request.data.get('latitude')
        lng = request.data.get('longitude')
        dist = request.data.get('distansia_metru', 0)
        estadu_absen = request.data.get('estadu_absensi', 'Ativu')

        if lat is None or lng is None:
            return Response({'error': 'Coordenadas falta'}, status=status.HTTP_400_BAD_REQUEST)

        konf = get_konfigurasaun()
        
        # Grava violasaun deit se distansia liu husi limite
        if float(dist) > konf.limite_raio_metru:
            ViolaLokalizasaun.objects.create(
                funsonariu=request.user,
                latitude=lat,
                longitude=lng,
                distansia_metru=dist,
                last_status=estadu_absen
            )
            return Response({'status': 'violasaun_registrada', 'message': 'Ita boot iha liur husi área kantór!'})

        return Response({'status': 'ok', 'message': 'Lokalizasaun seguru.'})

class PengajuanLemburView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = PediduLemburSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(funsonariu=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        queryset = PediduLembur.objects.filter(funsonariu=request.user).order_by('-tempu_pedidu')
        serializer = PediduLemburSerializer(queryset, many=True)
        return Response(serializer.data)
