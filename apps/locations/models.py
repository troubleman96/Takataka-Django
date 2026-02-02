from django.db import models


class Region(models.Model):
    code = models.CharField(max_length=10, unique=True)
    name_sw = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)

    class Meta:
        db_table = 'regions'

    def __str__(self):
        return self.name_en


class District(models.Model):
    region = models.ForeignKey(Region, on_delete=models.CASCADE, related_name='districts')
    code = models.CharField(max_length=10, unique=True)
    name_sw = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)

    class Meta:
        db_table = 'districts'

    def __str__(self):
        return self.name_en


class Ward(models.Model):
    district = models.ForeignKey(District, on_delete=models.CASCADE, related_name='wards')
    code = models.CharField(max_length=20, unique=True)
    name_sw = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    population = models.IntegerField(null=True, blank=True)
    area_sq_km = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    class Meta:
        db_table = 'wards'

    def __str__(self):
        return self.name_en


class Street(models.Model):
    ward = models.ForeignKey(Ward, on_delete=models.CASCADE, related_name='streets')
    name = models.CharField(max_length=200)
    description = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'streets'

    def __str__(self):
        return self.name
