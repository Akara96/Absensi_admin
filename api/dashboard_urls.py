from django.urls import path
from . import dashboard_views, views

urlpatterns = [
    path('', dashboard_views.dashboard_home, name='dashboard_home'),
    path('login/', dashboard_views.dashboard_login, name='dashboard_login'),
    path('logout/', dashboard_views.dashboard_logout, name='dashboard_logout'),
    path('pegawai/', dashboard_views.dashboard_pegawai, name='dashboard_pegawai'),
    path('pegawai/add/', dashboard_views.dashboard_pegawai_add, name='dashboard_pegawai_add'),
    path('pegawai/edit/<int:pegawai_id>/', dashboard_views.dashboard_pegawai_edit, name='dashboard_pegawai_edit'),
    path('pegawai/delete/<int:pegawai_id>/', dashboard_views.dashboard_pegawai_delete, name='dashboard_pegawai_delete'),
    path('pegawai/history/<int:pegawai_id>/', dashboard_views.dashboard_pegawai_history, name='dashboard_pegawai_history'),
    path('export/', views.UnduhExcelView.as_view(), name='export_absensi_excel'),
    
    # Konfigurasaun & Pedidu Lisensa
    path('konfigura/', dashboard_views.dashboard_pengaturan, name='dashboard_konfigura'),
    path('izin/', dashboard_views.dashboard_izin, name='dashboard_izin'),
    path('izin/<int:izin_id>/<str:action>/', dashboard_views.dashboard_izin_action, name='dashboard_izin_action'),
    path('konfigura/libur/delete/<int:libur_id>/', dashboard_views.dashboard_hari_libur_delete, name='dashboard_hari_libur_delete'),
]
