from django.db import models
from django.utils.timezone import now
from django.contrib.auth.models import User

class Config(models.Model):
    app_name = models.CharField(max_length=240, null=True, blank=True, verbose_name='Nombre Municipalidad')
    app_type = models.IntegerField(null=True, blank=True, verbose_name='Tipo Flujo')
    keppler = models.CharField(max_length=240, null=True, blank=True, default='', verbose_name='URL KEPPLER')
    base_url = models.CharField(max_length=240, null=True, blank=True, default='', verbose_name='URL BASE')
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')
    
    class Meta:
        verbose_name = 'Configuración'
        verbose_name_plural = 'Configuraciones'
        ordering = ['app_name']
    
    def __str__(self):
        return self.app_name

def logo(instance, filename):
    return 'admin/logo/' + filename
    
class Logo(models.Model):
    path = models.ImageField(upload_to=logo)
    state = models.CharField(max_length=240, default="Activa")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')

    class Meta:
        verbose_name = 'Logo'
        verbose_name_plural = 'Logos'
        ordering = ['created']
    
    def __str__(self):
        return self.path   