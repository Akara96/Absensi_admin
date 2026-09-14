from rest_framework import serializers
from .models import Funsonariu, Presensa, KonfigurasaunSistema, PediduLisensa


class FunsonariuSerializer(serializers.ModelSerializer):
    class Meta:
        model = Funsonariu
        fields = ['id', 'nre', 'naran', 'kargu', 'unidade_traballu', 'grau', 'numeru_telefoni', 'foto']


class PresensaSerializer(serializers.ModelSerializer):
    naran_funsonariu = serializers.CharField(source='funsonariu.naran', read_only=True)
    nre_funsonariu = serializers.CharField(source='funsonariu.nre', read_only=True)
    unidade_traballu = serializers.CharField(source='funsonariu.unidade_traballu', read_only=True)
    data = serializers.SerializerMethodField()
    oras_tama = serializers.SerializerMethodField()
    oras_sai_deskansa = serializers.SerializerMethodField()
    oras_tama_lokraik = serializers.SerializerMethodField()
    oras_sai = serializers.SerializerMethodField()
    durasaun_servisu = serializers.SerializerMethodField()

    def get_data(self, obj):
        return obj.tempu_tama.strftime('%Y-%m-%d')

    def get_oras_tama(self, obj):
        return obj.tempu_tama.strftime('%H:%M')

    def get_oras_sai_deskansa(self, obj):
        if obj.tempu_sai_deskansa:
            return obj.tempu_sai_deskansa.strftime('%H:%M')
        return None

    def get_oras_tama_lokraik(self, obj):
        if obj.tempu_tama_lokraik:
            return obj.tempu_tama_lokraik.strftime('%H:%M')
        return None

    def get_oras_sai(self, obj):
        if obj.tempu_sai:
            return obj.tempu_sai.strftime('%H:%M')
        return None

    def get_durasaun_servisu(self, obj):
        """Sura totál durasaun servisu husi sesaun 2 (dadersan + lokraik)."""
        total_detik = 0
        # Sesaun dadersan: tama → deskansa
        if obj.tempu_sai_deskansa:
            total_detik += (obj.tempu_sai_deskansa - obj.tempu_tama).total_seconds()
        # Sesaun lokraik: tama lokraik → sai/fila
        if obj.tempu_tama_lokraik and obj.tempu_sai:
            total_detik += (obj.tempu_sai - obj.tempu_tama_lokraik).total_seconds()

        if total_detik <= 0:
            return None
        total_menit = int(total_detik // 60)
        jam = total_menit // 60
        menit = total_menit % 60
        return f'{jam}o {menit}m'

    class Meta:
        model = Presensa
        fields = [
            'id', 'nre_funsonariu', 'naran_funsonariu', 'unidade_traballu',
            'data',
            'oras_tama', 'oras_sai_deskansa',
            'oras_tama_lokraik', 'oras_sai',
            'durasaun_servisu',
            'tempu_tama', 'tempu_sai_deskansa',
            'tempu_tama_lokraik', 'tempu_sai',
            'latitude', 'longitude', 'distansia_metru',
            'status', 'komentariu',
        ]


class PresensaInputSerializer(serializers.Serializer):
    """Serializer ba input husi Aplikasaun Flutter nian."""
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()
    distansia_metru = serializers.FloatField()
    tipe_absen = serializers.CharField(max_length=100)


class KonfigurasaunSistemaSerializer(serializers.ModelSerializer):
    class Meta:
        model = KonfigurasaunSistema
        fields = '__all__'


class PediduLisensaSerializer(serializers.ModelSerializer):
    naran_funsonariu = serializers.CharField(source='funsonariu.naran', read_only=True)
    status_display = serializers.CharField(source='get_status_pengajuan_display', read_only=True)
    tipe_izin_display = serializers.CharField(source='get_tipe_izin_display', read_only=True)

    class Meta:
        model = PediduLisensa
        fields = [
            'id', 'naran_funsonariu', 'tipe_izin', 'tipe_izin_display',
            'tanggal_mulai', 'tanggal_selesai', 'keterangan', 
            'file_bukti', 'status_pengajuan', 'status_display', 'waktu_pengajuan'
        ]
        read_only_fields = ['status_pengajuan', 'waktu_pengajuan', 'funsonariu']
