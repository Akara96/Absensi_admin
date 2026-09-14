from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    # Autentikasaun
    path('login/', views.LoginView.as_view(), name='api_login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Presensa
    path('absensi/', views.AbsensiView.as_view(), name='submit_absensi'),
    path('absensi/riwayat/', views.RiwayatAbsensiView.as_view(), name='riwayat_absensi'),
    path('absensi/status_hari_ini/', views.StatusHariIniView.as_view(), name='status_hari_ini'),

    # Konfigurasaun Sistema
    path('pengaturan/', views.PengaturanSistemView.as_view(), name='get_konfigurasaun_sistema'),

    # Pedidu Lisensa
    path('izin/', views.PengajuanIzinView.as_view(), name='submit_izin'),
    path('izin/histori/', views.PengajuanIzinView.as_view(), name='histori_izin'),

    # Monitoring
    path('monitor_lokalizasaun/', views.MonitorLokalizasaunView.as_view(), name='api_monitor_lokalizasaun'),

    # Export
    path('export/excel/', views.UnduhExcelView.as_view(), name='unduh_excel'),
]
