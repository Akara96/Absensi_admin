"""
Konfigurasaun URL ba projetu absensi_admin.

Lista `urlpatterns` mapia URL ba views. Informasaun liután, favor haree:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Ezemplu:
Function views
    1. Hatama import:  from my_app import views
    2. Hatama URL ba urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Hatama import:  from other_app.views import Home
    2. Hatama URL ba urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Hatama funsaun include(): from django.urls import include, path
    2. Hatama URL ba urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

from django.views.generic import RedirectView

urlpatterns = [
    path('', RedirectView.as_view(url='/dashboard/', permanent=False), name='index'),
    path('admin/', admin.site.urls),
    # Dashboard ho views kustom
    path('dashboard/', include('api.dashboard_urls')),
    # API Mobile
    path('api/', include('api.urls')),
    
    # Dokumentasaun API (Swagger)
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
]

# Servisu fatin file media nian
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
