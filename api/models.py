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


class ShiftServisu(models.Model):
    """Model ba oráriu shift servisu (Manhã, Tarde, dll)."""
    naran = models.CharField(max_length=100, verbose_name='Naran Shift')
    oras_tama_hahu = models.TimeField(default='06:00:00', verbose_name='Orijem Tama Dadersan')
    oras_tama_remata = models.TimeField(default='08:00:00', verbose_name='Limite Tama Dadersan')
    oras_sai_deskansa = models.TimeField(default='12:00:00', verbose_name='Orijem Deskansa')
    oras_tama_lokraik = models.TimeField(default='13:30:00', verbose_name='Orijem Tama Lokraik')
    oras_sai_lokraik = models.TimeField(default='17:30:00', verbose_name='Orijem Sai / Fila')

    class Meta:
        db_table = 'api_shift_servisu'
        verbose_name = 'Shift Servisu'
        verbose_name_plural = 'Shift Servisu sira'

    def __str__(self):
        return f"{self.naran} ({self.oras_tama_hahu.strftime('%H:%M')} - {self.oras_sai_lokraik.strftime('%H:%M')})"


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
    
    # --- New Fields for Features ---
    shift = models.ForeignKey(ShiftServisu, on_delete=models.SET_NULL, null=True, blank=True, verbose_name='Shift Servisu')
    kuota_cuti_anual = models.IntegerField(default=12, verbose_name='Kuota Cuti (Loron)')
    manajer = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='subordinados', verbose_name='Manajer/Atasan')
    device_id = models.CharField(max_length=255, null=True, blank=True, verbose_name='Device ID (HP)')
    # -------------------------------

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
        ('prezente', 'Prezente'),
        ('tardiu', 'Tardiu'),
        ('prezente_balun', 'Prezente Balun'),
        ('falta', 'Falta / La Iha'),
        ('horas_ekstra', 'Horas Ekstra'),
        ('lisensa', 'Lisensa / Izin'),
        ('moras', 'Moras'),
        ('ferias', 'Férias'),
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
        max_length=20, choices=STATUS_CHOICES, default='prezente', verbose_name='Estadu', db_index=True
    )
    komentariu = models.TextField(blank=True, verbose_name='Komentáriu')
    durasaun_horas_ekstra = models.FloatField(default=0.0, verbose_name='Durasaun Horas Ekstra (Jam)')

    def __str__(self):
        return f"{self.funsonariu.naran} - {self.tempu_tama.strftime('%d/%m/%Y %H:%M')}"

    class Meta:
        db_table = 'api_presensa'
        verbose_name = 'Presensa'
        verbose_name_plural = 'Rekapitulasaun Presensa'
        ordering = ['-tempu_tama']


class KonfigurasaunSistema(models.Model):
    """Model ba konfigurasaun oráriu servisu dinámiku."""
    oras_tama_hahu = models.TimeField(default='06:00:00', verbose_name='Orijem Tama Dadersan')
    oras_tama_remata = models.TimeField(default='08:00:00', verbose_name='Limite Tama Dadersan')
    oras_sai_deskansa = models.TimeField(default='12:00:00', verbose_name='Orijem Deskansa')
    oras_tama_lokraik = models.TimeField(default='13:30:00', verbose_name='Orijem Tama Lokraik')
    oras_sai_lokraik = models.TimeField(default='17:30:00', verbose_name='Orijem Sai / Fila')
    limite_raio_metru = models.IntegerField(default=50, verbose_name='Raio GPS (Metru)')
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
        ('moras', 'Moras (Sakit)'),
        ('lisensa', 'Lisensa (Izin)'),
        ('ferias', 'Férias (Cuti)'),
        ('urjente', 'Mendesak (Emergency)'),
    ]
    STATUS_PENGAJUAN_CHOICES = [
        ('hein', 'Hein (Pending)'),
        ('aprova', 'Aprova (Approved)'),
        ('rejeita', 'Rejeita (Rejected)'),
    ]

    funsonariu = models.ForeignKey(Funsonariu, on_delete=models.CASCADE, related_name='pedidu_lisensa', verbose_name='Funsonáriu')
    tipu_lisensa = models.CharField(max_length=10, choices=TIPE_IZIN_CHOICES, verbose_name='Tipe Izin')
    data_hahu = models.DateField(verbose_name='Data Hahu')
    data_remata = models.DateField(verbose_name='Data Remata')
    razaun = models.TextField(verbose_name='Razaun / Komentáriu')
    file_evidensia = models.ImageField(upload_to='bukti_izin/', verbose_name='Foto Evidénsia / Surat')
    
    # --- Multi-level Approval ---
    estadu_manajer = models.CharField(max_length=20, choices=STATUS_PENGAJUAN_CHOICES, default='hein', verbose_name='Aprovamentu Manajer')
    estadu_pedidu = models.CharField(max_length=20, choices=STATUS_PENGAJUAN_CHOICES, default='hein', verbose_name='Aprovamentu Final (HR)')
    # ----------------------------
    
    tempu_pedidu = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'api_pedidu_lisensa'
        verbose_name = 'Pedidu Lisensa'
        verbose_name_plural = 'Pedidu Lisensa sira'
        ordering = ['-tempu_pedidu']
        
    def save(self, *args, **kwargs):
        # Kurangi kuota cuti jika disetujui (HR) dan tipe ferias (cuti) atau izin
        if self.pk:
            try:
                old_instance = PediduLisensa.objects.get(pk=self.pk)
                if old_instance.estadu_pedidu != 'aprova' and self.estadu_pedidu == 'aprova':
                    if self.tipu_lisensa in ['ferias', 'lisensa']:
                        durasaun = (self.data_remata - self.data_hahu).days + 1
                        if durasaun > 0 and self.funsonariu.kuota_cuti_anual >= durasaun:
                            self.funsonariu.kuota_cuti_anual -= durasaun
                            self.funsonariu.save()
            except PediduLisensa.DoesNotExist:
                pass
        super().save(*args, **kwargs)


class LoronFeriadu(models.Model):
    """Model ba rejistu loron feriadu / libur."""
    data_feriadu = models.DateField(unique=True, verbose_name='Data Libur')
    katerangan = models.CharField(max_length=200, verbose_name='Katerangan Libur')

    class Meta:
        db_table = 'api_loron_feriadu'
        verbose_name = 'Loron Feriadu'
        verbose_name_plural = 'Loron Feriadu'
        ordering = ['-data_feriadu']

    def __str__(self):
        return f"{self.data_feriadu} - {self.katerangan}"


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

class PediduLembur(models.Model):
    """Model ba pedidu horas ekstra (Overtime)."""
    STATUS_CHOICES = [
        ('hein', 'Hein (Pending)'),
        ('aprova', 'Aprova (Approved)'),
        ('rejeita', 'Rejeita (Rejected)'),
    ]
    
    funsonariu = models.ForeignKey(Funsonariu, on_delete=models.CASCADE, related_name='pedidu_lembur', verbose_name='Funsonáriu')
    data_lembur = models.DateField(verbose_name='Data Lembur')
    oras_hahu = models.TimeField(verbose_name='Oras Hahu')
    oras_remata = models.TimeField(verbose_name='Oras Remata')
    razaun = models.TextField(verbose_name='Razaun / Tarefa')
    
    estadu_manajer = models.CharField(max_length=20, choices=STATUS_CHOICES, default='hein', verbose_name='Aprovamentu Manajer')
    estadu_hr = models.CharField(max_length=20, choices=STATUS_CHOICES, default='hein', verbose_name='Aprovamentu Final (HR)')
    
    tempu_pedidu = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'api_pedidu_lembur'
        verbose_name = 'Pedidu Lembur'
        verbose_name_plural = 'Pedidu Lembur sira'
        ordering = ['-data_lembur', '-tempu_pedidu']
        
    def __str__(self):
        return f"Lembur: {self.funsonariu.naran} ({self.data_lembur})"
