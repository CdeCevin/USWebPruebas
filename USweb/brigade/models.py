from django.db import models
from django.utils.timezone import now
from django.contrib.auth.models import User

class Brigade(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=0)
    state = models.CharField(max_length=100, null=True, blank=True, verbose_name='Estado',default="Activo")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')
    
    class Meta:
        verbose_name = 'Cuadrilla'
        verbose_name_plural = 'Cuadrillas'
        ordering = ['state']
    
    def __str__(self):
        return self.user