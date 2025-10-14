from django.db import models
from django.utils.timezone import now
from django.contrib.auth.models import User
from management.models import Management

class Deparment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=0)
    management = models.ForeignKey(Management, on_delete=models.CASCADE, default=0)
    deparment_name = models.CharField(max_length=240, null=True, blank=True, verbose_name='Departamento', default="N/A")
    deparment_in_charge = models.CharField(max_length=240, null=True, blank=True, verbose_name='Encargado', default="N/A")
    deparment_in_charge_mail = models.CharField(max_length=240, null=True, blank=True, verbose_name='Encargado Correo', default="N/A")
    state = models.CharField(max_length=100, null=True, blank=True, verbose_name='Estado',default="Activo")
    created = models.DateTimeField(auto_now_add=True,verbose_name='Fecha Creación')
    updated = models.DateTimeField(auto_now=True,verbose_name='Fecha Actualización')
    
    class Meta:
        verbose_name = 'Departamento'
        verbose_name_plural = 'Departamentos'
        ordering = ['deparment_name']
    
    def __str__(self):
        return self.deparment_name

