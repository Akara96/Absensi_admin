from django.contrib import admin
from .models import Funsonariu, Presensa, KonfigurasaunSistema, PediduLisensa, LoronFeriadu, ShiftServisu, PediduLembur


@admin.register(ShiftServisu)
class ShiftServisuAdmin(admin.ModelAdmin):
    list_display = ('naran', 'oras_tama_hahu', 'oras_sai_lokraik')
    search_fields = ('naran',)

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
        ('Informasaun Kargu & Shift', {
            'fields': ('kargu', 'unidade_traballu', 'grau', 'shift', 'manajer')
        }),
        ('Kontaktu', {
            'fields': ('numeru_telefoni',)
        }),
        ('Atributu Avansadu', {
            'fields': ('kuota_cuti_anual', 'device_id')
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
    list_display = ('oras_tama_hahu', 'oras_tama_remata', 'limite_raio_metru', 'updated_at')


@admin.register(PediduLisensa)
class PediduLisensaAdmin(admin.ModelAdmin):
    list_display = ('funsonariu', 'tipu_lisensa', 'data_hahu', 'data_remata', 'estadu_manajer', 'estadu_pedidu')
    list_filter = ('estadu_pedidu', 'estadu_manajer', 'tipu_lisensa')
    search_fields = ('funsonariu__naran',)


@admin.register(LoronFeriadu)
class LoronFeriaduAdmin(admin.ModelAdmin):
    list_display = ('data_feriadu', 'katerangan')
    ordering = ('-data_feriadu',)

@admin.register(PediduLembur)
class PediduLemburAdmin(admin.ModelAdmin):
    list_display = ('funsonariu', 'data_lembur', 'oras_hahu', 'oras_remata', 'estadu_manajer', 'estadu_hr')
    list_filter = ('estadu_hr', 'estadu_manajer')
    search_fields = ('funsonariu__naran',)


# Kustomizasaun header Django Admin
admin.site.site_header = "Painel Administrasaun Sistema Presensa"
admin.site.site_title = "Presensa Admin"
admin.site.index_title = "Bem-vindu ba Painel Administrasaun"
