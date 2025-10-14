from django.db import models

class Manuals(models.Model):
    manual_name = models.CharField(max_length=240, null=True, blank=True, verbose_name='Manual', default="N/A")
    manual_path = models.CharField(max_length=240, null=True, blank=True, verbose_name='Ubicación', default="N/A")
    manual_description= models.TextField(max_length=240, null=True, blank=True, verbose_name='Descripción', default="N/A")
    
    class Meta:
        verbose_name = 'Manual'
        verbose_name_plural = 'Manuales'
        ordering = ['manual_name']
    
    def __str__(self):
        return self.manual_name