from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager


class FunsonariuManager(BaseUserManager):
    """Maneja kria uza-na'in ba Funsonáriu."""
    def create_user(self, nre, naran, password=None, **extra_fields):
        if not nre:
            raise ValueError('NRE tenke hatama')
        user = self.model(nre=nre, naran=naran, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, nre, naran, password=None, **extra_fields):
        extra_fields.setdefault('is_admin', True)
        extra_fields.setdefault('is_active', True)
        return self.create_user(nre, naran, password, **extra_fields)


class Funsonariu(AbstractBaseUser):
    """Model prinsipál ba funsonáriu / servisu-na'in instansi."""

    GRAU_CHOICES = [
        ('I', 'Grau I'),
        ('II', 'Grau II'),
        ('III', 'Grau III'),
        ('IV', 'Grau IV'),
    ]

    nre = models.CharField(max_length=20, unique=True, verbose_name='NRE')
    naran = models.CharField(max_length=100, verbose_name='Naran Kompletu')
    kargu = models.CharField(max_length=100, blank=True, verbose_name='Kargu')
    unidade_traballu = models.CharField(max_length=100, blank=True, verbose_name='Departamentu', db_index=True)
    grau = models.CharField(
        max_length=5, choices=GRAU_CHOICES, blank=True, verbose_name='Grau'
    )
    numeru_telefoni = models.CharField(max_length=20, blank=True, verbose_name='Númeru Telefoni')
    foto = models.ImageField(upload_to='foto_pegawai/', blank=True, null=True)
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)
    data_tama = models.DateField(auto_now_add=True)

    USERNAME_FIELD = 'nre'
    REQUIRED_FIELDS = ['naran']

    class Meta:
        db_table = 'api_funsonariu'
        verbose_name = 'Funsonáriu'
        verbose_name_plural = 'Funsonáriu Sira'
        ordering = ['naran']

    objects = FunsonariuManager()

    def __str__(self):
        return f"{self.nre} - {self.naran}"

    @property
    def is_staff(self):
        return self.is_admin

    def has_perm(self, perm, obj=None):
        return self.is_admin

    def has_module_perms(self, app_label):
        return self.is_admin


class Presensa(models.Model):
    """Model rejistu presensa dadersan no lokraik."""

    STATUS_CHOICES = [
        ('hadir', 'Prezente'),
        ('terlambat', 'Tardiu'),
        ('hadir_sebagian', 'Prezente Balun'),
        ('alpha', 'Falta / La Iha'),
        ('lembur', 'Horas Ekstra'),
        ('izin', 'Lisensa / Izin'),
        ('sakit', 'Moras'),
        ('cuti', 'Férias'),
    ]

    funsonariu = models.ForeignKey(
        Funsonariu, on_delete=models.CASCADE, related_name='presensa', verbose_name='Funsonáriu'
    )
    tempu_tama = models.DateTimeField(auto_now_add=True, verbose_name='Tama Dadersan', db_index=True)
    tempu_sai_deskansa = models.DateTimeField(null=True, blank=True, verbose_name='Deskansa')
    tempu_tama_lokraik = models.DateTimeField(null=True, blank=True, verbose_name='Tama Lokraik')
    tempu_sai = models.DateTimeField(null=True, blank=True, verbose_name='Sai / Fila Lokraik')
    latitude = models.FloatField(verbose_name='Latitude GPS')
    longitude = models.FloatField(verbose_name='Longitude GPS')
    distansia_metru = models.FloatField(verbose_name='Distánsia ba Kantór (metru)')
    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default='hadir', verbose_name='Estadu', db_index=True
    )
    komentariu = models.TextField(blank=True, verbose_name='Komentáriu')
    durasi_lembur = models.FloatField(default=0.0, verbose_name='Durasaun Horas Ekstra (Jam)')

    def __str__(self):
        return f"{self.funsonariu.naran} - {self.tempu_tama.strftime('%d/%m/%Y %H:%M')}"

    class Meta:
        db_table = 'api_presensa'
        verbose_name = 'Presensa'
        verbose_name_plural = 'Rekapitulasaun Presensa'
        ordering = ['-tempu_tama']


class KonfigurasaunSistema(models.Model):
    """Model ba konfigurasaun oráriu servisu dinámiku."""
    jam_masuk_mulai = models.TimeField(default='06:00:00', verbose_name='Orijem Tama Dadersan')
    jam_masuk_akhir = models.TimeField(default='08:00:00', verbose_name='Limite Tama Dadersan')
    jam_keluar_istirahat = models.TimeField(default='12:00:00', verbose_name='Orijem Deskansa')
    jam_masuk_siang = models.TimeField(default='13:30:00', verbose_name='Orijem Tama Lokraik')
    jam_keluar_sore = models.TimeField(default='17:30:00', verbose_name='Orijem Sai / Fila')
    batas_radius_meter = models.IntegerField(default=50, verbose_name='Raio GPS (Metru)')
    updated_at = models.DateTimeField(auto_now=True)
    last_message = models.CharField(max_length=255, blank=True, verbose_name='Mensajen ikus ba App')

    class Meta:
        db_table = 'api_konfigurasaun_sistema'
        verbose_name = 'Konfigurasaun Sistema'
        verbose_name_plural = 'Konfigurasaun Sistema'

    def __str__(self):
        return "Preferénsia Oráriu Servisu"

    def save(self, *args, **kwargs):
        if not self.pk and KonfigurasaunSistema.objects.exists():
            return
        super().save(*args, **kwargs)


class PediduLisensa(models.Model):
    """Model ba pedidu lisensa/cuti staff nian."""
    TIPE_IZIN_CHOICES = [
        ('sakit', 'Moras (Sakit)'),
        ('izin', 'Lisensa (Izin)'),
        ('cuti', 'Férias (Cuti)'),
        ('mendesak', 'Mendesak (Emergency)'),
    ]
    STATUS_PENGAJUAN_CHOICES = [
        ('menunggu', 'Hein (Pending)'),
        ('disetujui', 'Aprova (Approved)'),
        ('ditolak', 'Rejeita (Rejected)'),
    ]

    funsonariu = models.ForeignKey(Funsonariu, on_delete=models.CASCADE, related_name='pedidu_lisensa', verbose_name='Funsonáriu')
    tipe_izin = models.CharField(max_length=10, choices=TIPE_IZIN_CHOICES, verbose_name='Tipe Izin')
    tanggal_mulai = models.DateField(verbose_name='Data Hahu')
    tanggal_selesai = models.DateField(verbose_name='Data Remata')
    keterangan = models.TextField(verbose_name='Razaun / Komentáriu')
    file_bukti = models.ImageField(upload_to='bukti_izin/', verbose_name='Foto Evidénsia / Surat')
    status_pengajuan = models.CharField(max_length=20, choices=STATUS_PENGAJUAN_CHOICES, default='menunggu', verbose_name='Estadu Pedidu')
    waktu_pengajuan = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'api_pedidu_lisensa'
        verbose_name = 'Pedidu Lisensa'
        verbose_name_plural = 'Pedidu Lisensa sira'
        ordering = ['-waktu_pengajuan']


class LoronFeriadu(models.Model):
    """Model ba rejistu loron feriadu / libur."""
    tanggal = models.DateField(unique=True, verbose_name='Data Libur')
    keterangan = models.CharField(max_length=200, verbose_name='Katerangan Libur')

    class Meta:
        db_table = 'api_loron_feriadu'
        verbose_name = 'Loron Feriadu'
        verbose_name_plural = 'Loron Feriadu'
        ordering = ['-tanggal']

    def __str__(self):
        return f"{self.tanggal} - {self.keterangan}"


class ViolaLokalizasaun(models.Model):
    """Model ba rejistu violasaun geofence (sai husi kantór tempu servisu)."""
    funsonariu = models.ForeignKey(Funsonariu, on_delete=models.CASCADE, related_name='violasaun_gps', verbose_name='Funsonáriu')
    tempu = models.DateTimeField(auto_now_add=True, verbose_name='Tempu Detekta')
    latitude = models.FloatField()
    longitude = models.FloatField()
    distansia_metru = models.FloatField(verbose_name='Distánsia (m)')
    last_status = models.CharField(max_length=50, verbose_name='Estadu Absensi')

    class Meta:
        db_table = 'api_violasaun_gps'
        verbose_name = 'Violação Geofence'
        verbose_name_plural = 'Violação Geofence sira'
        ordering = ['-tempu']

    def __str__(self):
        return f"{self.funsonariu.naran} - {self.tempu.strftime('%H:%M')} ({self.distansia_metru:.1f}m)"
