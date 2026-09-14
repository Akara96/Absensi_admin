from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required, user_passes_test
from django.utils import timezone
from django.db.models import Count, Q
from django.db.models.functions import TruncDate
from datetime import date, timedelta
from .models import Funsonariu, Presensa, KonfigurasaunSistema, PediduLisensa, LoronFeriadu
from .views import OFFICE_LAT, OFFICE_LNG

def is_admin(user):
    return user.is_authenticated and user.is_admin


def get_common_context(request):
    """Retorna contextu komun ba dashboard (notifikasaun, etc)."""
    from .models import ViolaLokalizasaun
    hari_ini = date.today()
    izin_count = PediduLisensa.objects.filter(estadu_pedidu='hein').count()
    lembur_count = Presensa.objects.filter(tempu_tama__date=hari_ini, durasaun_horas_ekstra__gt=0).count()
    violasaun_list = ViolaLokalizasaun.objects.filter(tempu__date=hari_ini).select_related('funsonariu')[:5]
    
    return {
        'admin_nama': request.user.naran if request.user.is_authenticated else '',
        'izin_pending_count': izin_count,
        'lembur_count_today': lembur_count,
        'violasaun_list': violasaun_list,
        'violasaun_count': violasaun_list.count(),
    }


def dashboard_login(request):
    """Halaman Login ba Admin Web."""
    if request.user.is_authenticated and request.user.is_admin:
        return redirect('dashboard_home')

    error = None
    if request.method == 'POST':
        nre = request.POST.get('nre', '').strip()
        password = request.POST.get('password', '').strip()

        try:
            funsonariu = Funsonariu.objects.get(nre=nre, is_admin=True)
            if funsonariu.check_password(password):
                login(request, funsonariu, backend='django.contrib.auth.backends.ModelBackend')
                return redirect('dashboard_home')
            else:
                error = 'NRE ka password sala.'
        except Funsonariu.DoesNotExist:
            error = 'Kontu admin la hetan.'

    return render(request, 'dashboard/login.html', {'error': error})


def dashboard_logout(request):
    logout(request)
    return redirect('dashboard_login')


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_home(request):
    """Halaman prinsipál dashboard rekapitulasaun presensa."""
    hari_ini = date.today()
    
    # Filtru husi URL
    filter_tanggal = request.GET.get('tanggal', hari_ini.strftime('%Y-%m-%d'))
    filter_unit = request.GET.get('unidade_traballu', '')
    filter_nama = request.GET.get('naran', '')

    try:
        tanggal_target = date.fromisoformat(filter_tanggal)
    except ValueError:
        tanggal_target = hari_ini

    # Query presensa tuir filtru
    presensa_qs = Presensa.objects.filter(
        tempu_tama__date=tanggal_target
    ).select_related('funsonariu')

    if filter_unit:
        presensa_qs = presensa_qs.filter(funsonariu__unidade_traballu__icontains=filter_unit)
    if filter_nama:
        presensa_qs = presensa_qs.filter(funsonariu__naran__icontains=filter_nama)

    # Estatístika ringkasan
    total_funsonariu = Funsonariu.objects.filter(is_active=True).count()
    hadir_hari_ini = Presensa.objects.filter(tempu_tama__date=hari_ini).count()
    terlambat_hari_ini = Presensa.objects.filter(
        tempu_tama__date=hari_ini, status='tardiu'
    ).count()
    tidak_hadir = total_funsonariu - hadir_hari_ini

    # Lista departamentu ba dropdown filtru
    unit_kerja_list = Funsonariu.objects.values_list('unidade_traballu', flat=True).distinct().exclude(unidade_traballu='')

    # Estatístika Pedidu Lisensa & Lembur
    izin_pending_count = PediduLisensa.objects.filter(estadu_pedidu='hein').count()
    lembur_qs = Presensa.objects.filter(tempu_tama__date=hari_ini, durasaun_horas_ekstra__gt=0).select_related('funsonariu')
    lembur_count_today = lembur_qs.count()

    context = get_common_context(request)
    context.update({
        'presensa_list': presensa_qs,
        'tanggal_target': tanggal_target,
        'filter_unit': filter_unit,
        'filter_nama': filter_nama,
        'total_funsonariu': total_funsonariu,
        'hadir_hari_ini': hadir_hari_ini,
        'terlambat_hari_ini': terlambat_hari_ini,
        'tidak_hadir': tidak_hadir,
        'unit_kerja_list': unit_kerja_list,
        'lembur_list_today': lembur_qs,
    })

    # Data ba Grafik (loron 7 ikus)
    last_7_days = []
    for i in range(6, -1, -1):
        last_7_days.append(hari_ini - timedelta(days=i))
    
    chart_labels = [d.strftime('%d %b') for d in last_7_days]
    chart_hadir = []
    chart_terlambat = []
    chart_falta = []
    
    total_staf = Funsonariu.objects.filter(is_active=True).count()
    
    for d in last_7_days:
        h = Presensa.objects.filter(tempu_tama__date=d, status='prezente').count()
        t = Presensa.objects.filter(tempu_tama__date=d, status='tardiu').count()
        f = max(0, total_staf - (h + t))
        
        chart_hadir.append(h)
        chart_terlambat.append(t)
        chart_falta.append(f)
        
    context.update({
        'chart_labels': chart_labels,
        'chart_hadir': chart_hadir,
        'chart_terlambat': chart_terlambat,
        'chart_falta': chart_falta,
    })
    return render(request, 'dashboard/home.html', context)


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_pegawai(request):
    """Halaman kestiona dadus funsonáriu."""
    filter_nama = request.GET.get('naran', '').strip()
    filter_unit = request.GET.get('unidade_traballu', '').strip()

    funsonariu_qs = Funsonariu.objects.all().order_by('naran')

    if filter_nama:
        funsonariu_qs = funsonariu_qs.filter(
            Q(naran__icontains=filter_nama) | Q(nre__icontains=filter_nama)
        )
    if filter_unit:
        funsonariu_qs = funsonariu_qs.filter(unidade_traballu__icontains=filter_unit)

    # Estatístika
    total_funsonariu = Funsonariu.objects.count()
    active_funsonariu = Funsonariu.objects.filter(is_active=True).count()
    unit_kerja_list = Funsonariu.objects.values_list('unidade_traballu', flat=True).distinct().exclude(unidade_traballu='')
    unit_count = unit_kerja_list.count()

    context = get_common_context(request)
    context.update({
        'funsonariu_list': funsonariu_qs,
        'total_pegawai': total_funsonariu,
        'active_pegawai': active_funsonariu,
        'unit_count': unit_count,
        'unit_kerja_list': unit_kerja_list,
        'filter_nama': filter_nama,
        'filter_unit': filter_unit,
    })
    return render(request, 'dashboard/funsonariu.html', context)


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_pegawai_add(request):
    """Hatama funsonáriu foun husi dashboard."""
    error = None
    if request.method == 'POST':
        nre = request.POST.get('nre', '').strip()
        naran = request.POST.get('naran', '').strip()
        password = request.POST.get('password', '').strip()
        unidade = request.POST.get('unidade_traballu', '').strip()
        kargu = request.POST.get('kargu', '').strip()
        foto = request.FILES.get('foto')

        if not nre or not naran or not password:
            error = "Favor prienxe maktu hotu-hotu (NRE, Naran, Password)."
        elif Funsonariu.objects.filter(nre=nre).exists():
            error = f"NRE {nre} rejista ona iha sistema."
        else:
            try:
                Funsonariu.objects.create_user(
                    nre=nre,
                    naran=naran,
                    password=password,
                    unidade_traballu=unidade,
                    kargu=kargu,
                    foto=foto
                )
                return redirect('dashboard_pegawai')
            except Exception as e:
                error = f"Mosu sala: {str(e)}"

    context = get_common_context(request)
    context.update({'error': error})
    return render(request, 'dashboard/funsonariu_add.html', context)


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_pegawai_edit(request, pegawai_id):
    """Edit dadus funsonáriu."""
    try:
        funsonariu = Funsonariu.objects.get(id=pegawai_id)
    except Funsonariu.DoesNotExist:
        return redirect('dashboard_pegawai')

    error = None
    success = None
    if request.method == 'POST':
        nre = request.POST.get('nre', '').strip()
        naran = request.POST.get('naran', '').strip()
        password = request.POST.get('password', '').strip()
        unidade = request.POST.get('unidade_traballu', '').strip()
        kargu = request.POST.get('kargu', '').strip()
        is_active = request.POST.get('is_active') == 'on'
        foto = request.FILES.get('foto')

        if not nre or not naran:
            error = "NRE ho Naran la bele mamuk."
        elif Funsonariu.objects.filter(nre=nre).exclude(id=pegawai_id).exists():
            error = f"NRE {nre} rejista ona hosi funsonáriu seluk."
        else:
            try:
                funsonariu.nre = nre
                funsonariu.naran = naran
                funsonariu.unidade_traballu = unidade
                funsonariu.kargu = kargu
                funsonariu.is_active = is_active
                if foto:
                    funsonariu.foto = foto
                if password:
                    funsonariu.set_password(password)
                funsonariu.save()
                success = "Dadus funsonáriu update susesu!"
            except Exception as e:
                error = f"Mosu sala: {str(e)}"

    context = get_common_context(request)
    context.update({
        'pegawai': funsonariu,
        'error': error,
        'success': success,
    })
    return render(request, 'dashboard/funsonariu_edit.html', context)


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_pegawai_delete(request, pegawai_id):
    """Hamos dadus funsonáriu."""
    Funsonariu.objects.filter(id=pegawai_id).delete()
    return redirect('dashboard_pegawai')


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_pegawai_history(request, pegawai_id):
    """Istória presensa funsonáriu individuál."""
    try:
        funsonariu = Funsonariu.objects.get(id=pegawai_id)
    except Funsonariu.DoesNotExist:
        return redirect('dashboard_pegawai')

    presensa_qs = Presensa.objects.filter(funsonariu=funsonariu).order_by('-tempu_tama')
    
    # Estatístika Individuál
    total_hadir = presensa_qs.filter(status='prezente').count()
    total_terlambat = presensa_qs.filter(status='tardiu').count()
    total_izin = presensa_qs.filter(status__in=['lisensa', 'moras', 'ferias', 'urjente']).count()

    context = get_common_context(request)
    context.update({
        'pegawai': funsonariu,
        'absensi_list': presensa_qs,
        'total_hadir': total_hadir,
        'total_terlambat': total_terlambat,
        'total_izin': total_izin,
    })
    return render(request, 'dashboard/funsonariu_history.html', context)


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_pengaturan(request):
    """Halaman Konfigurasaun Sistema"""
    konf, created = KonfigurasaunSistema.objects.get_or_create(id=1)
    loron_libur_list = LoronFeriadu.objects.all()
    
    if request.method == 'POST':
        action = request.POST.get('action')
        
        if action == 'save_pengaturan':
            konf.oras_tama_hahu = request.POST.get('oras_tama_hahu')
            konf.oras_tama_remata = request.POST.get('oras_tama_remata')
            konf.oras_sai_deskansa = request.POST.get('oras_sai_deskansa')
            konf.oras_tama_lokraik = request.POST.get('oras_tama_lokraik')
            konf.oras_sai_lokraik = request.POST.get('oras_sai_lokraik')
            konf.limite_raio_metru = request.POST.get('limite_raio_metru')
            # Buat notifikasi lebih detail
            konf.last_message = f"Oráriu foun: Tama ({konf.oras_tama_hahu} - {konf.oras_tama_remata}), Deskansa ({konf.oras_sai_deskansa}), Tama Lokraik ({konf.oras_tama_lokraik}), Sai ({konf.oras_sai_lokraik}), Raio GPS: {konf.limite_raio_metru}m."
            konf.save()
            return redirect('dashboard_konfigura')
            
        elif action == 'add_libur':
            tgl = request.POST.get('tanggal')
            ket = request.POST.get('keterangan')
            if tgl and ket:
                LoronFeriadu.objects.get_or_create(data_feriadu=tgl, defaults={'katerangan': ket})
                konf.last_message = f"Feriadu foun input: {ket} iha data {tgl}."
                konf.save()
            return redirect('dashboard_konfigura')
            
    context = get_common_context(request)
    context.update({
        'pengaturan': konf,
        'hari_libur_list': loron_libur_list,
    })
    return render(request, 'dashboard/konfigura.html', context)


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_hari_libur_delete(request, libur_id):
    """Hamos loron feriadu."""
    try:
        libur = LoronFeriadu.objects.get(id=libur_id)
        msg_delete = f"Feriadu '{libur.katerangan}' ({libur.data_feriadu}) hamoos ona."
        libur.delete()
    except LoronFeriadu.DoesNotExist:
        msg_delete = "Loron feriadu la hetan."
        
    konf, _ = KonfigurasaunSistema.objects.get_or_create(id=1)
    konf.last_message = msg_delete
    konf.save()
    return redirect('dashboard_konfigura')


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_izin(request):
    """Halaman Kestiona Pedidu Lisensa."""
    izin_list = PediduLisensa.objects.all().order_by('-tempu_pedidu')
    context = get_common_context(request)
    context.update({'izin_list': izin_list})
    return render(request, 'dashboard/izin.html', context)


@login_required(login_url='dashboard_login')
@user_passes_test(is_admin, login_url='dashboard_login')
def dashboard_izin_action(request, izin_id, action):
    """Action ba aprova/rejeita pedidu lisensa."""
    try:
        pedidu = PediduLisensa.objects.get(id=izin_id)
        if action == 'approve':
            pedidu.estadu_pedidu = 'aprova'
            # Update dadus presensa iha loron lisensa nian
            delta = pedidu.data_remata - pedidu.data_hahu
            for i in range(delta.days + 1):
                tgl = pedidu.data_hahu + timedelta(days=i)
                from datetime import datetime, time
                dt_tama = timezone.make_aware(datetime.combine(tgl, time(8, 0, 0)))
                Presensa.objects.update_or_create(
                    funsonariu=pedidu.funsonariu,
                    tempu_tama__date=tgl,
                    defaults={
                        'tempu_tama': dt_tama,
                        'tempu_sai': dt_tama + timedelta(hours=9),
                        'latitude': OFFICE_LAT,
                        'longitude': OFFICE_LNG,
                        'distansia_metru': 0,
                        'status': pedidu.tipu_lisensa,
                        'komentariu': f"Aprova hosi Web Admin (Razaun: {pedidu.razaun})"
                    }
                )
        elif action == 'reject':
            pedidu.estadu_pedidu = 'rejeita'
        pedidu.save()
    except PediduLisensa.DoesNotExist:
        pass
    
    return redirect('dashboard_izin')
