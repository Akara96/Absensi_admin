from django.contrib import admin
from .models import Funsonariu, Presensa, KonfigurasaunSistema, PediduLisensa, LoronFeriadu


@admin.register(Funsonariu)
class FunsonariuAdmin(admin.ModelAdmin):
    list_display = ('nre', 'naran', 'kargu', 'unidade_traballu', 'grau', 'is_active', 'data_tama')
    list_filter = ('unidade_traballu', 'grau', 'is_active')
    search_fields = ('nre', 'naran', 'kargu')
    ordering = ('naran',)
    readonly_fields = ('data_tama',)

    fieldsets = (
        ('Identidade Funsonáriu', {
            'fields': ('nre', 'naran', 'foto')
        }),
        ('Informasaun Kargu', {
            'fields': ('kargu', 'unidade_traballu', 'grau')
        }),
        ('Kontaktu', {
            'fields': ('numeru_telefoni',)
        }),
        ('Estadu Kontu', {
            'fields': ('is_active', 'is_admin', 'data_tama')
        }),
    )

    def save_model(self, request, obj, form, change):
        """Enkripasaun password wanhira rai husi admin."""
        if 'password' in form.changed_data:
            obj.set_password(obj.password)
        super().save_model(request, obj, form, change)


@admin.register(Presensa)
class PresensaAdmin(admin.ModelAdmin):
    list_display = ('funsonariu', 'tempu_tama', 'status', 'distansia_metru', 'komentariu')
    list_filter = ('status', 'tempu_tama', 'funsonariu__unidade_traballu')
    search_fields = ('funsonariu__naran', 'funsonariu__nre')
    date_hierarchy = 'tempu_tama'
    readonly_fields = ('funsonariu', 'tempu_tama', 'latitude', 'longitude', 'distansia_metru')
    ordering = ('-tempu_tama',)


@admin.register(KonfigurasaunSistema)
class KonfigurasaunSistemaAdmin(admin.ModelAdmin):
    list_display = ('jam_masuk_mulai', 'jam_masuk_akhir', 'batas_radius_meter', 'updated_at')


@admin.register(PediduLisensa)
class PediduLisensaAdmin(admin.ModelAdmin):
    list_display = ('funsonariu', 'tipe_izin', 'tanggal_mulai', 'tanggal_selesai', 'status_pengajuan')
    list_filter = ('status_pengajuan', 'tipe_izin')
    search_fields = ('funsonariu__naran',)


@admin.register(LoronFeriadu)
class LoronFeriaduAdmin(admin.ModelAdmin):
    list_display = ('tanggal', 'keterangan')
    ordering = ('-tanggal',)


# Kustomizasaun header Django Admin
admin.site.site_header = "Painel Administrasaun Sistema Presensa"
admin.site.site_title = "Presensa Admin"
admin.site.index_title = "Bem-vindu ba Painel Administrasaun"
