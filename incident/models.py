from django.db import models
from django.utils.timezone import now
from django.contrib.auth.models import User
from department.models import Deparment
from management.models import Management

class Incident(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=0)
    management = models.ForeignKey(Management, on_delete=models.CASCADE, default=0)
    deparment = models.ForeignKey(Deparment, on_delete=models.CASCADE, default=0)
    name = models.CharField(max_length=240, null=True, blank=True, verbose_name='Incidente', default="N/A")
    state = models.CharField(max_length=100, null=True, blank=True, verbose_name='Estado',default="Activo")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')
    
    class Meta:
        verbose_name = 'Incidente'
        verbose_name_plural = 'Incidentes'
        ordering = ['name']
    
    def __str__(self):
        return self.name

