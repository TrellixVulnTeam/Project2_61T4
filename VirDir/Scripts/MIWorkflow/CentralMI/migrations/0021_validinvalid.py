# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2018-10-13 14:12
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('CentralMI', '0020_assignview_tblnavbarview_teammetricsdata_viewtype'),
    ]

    operations = [
        migrations.CreateModel(
            name='ValidInvalid',
            fields=[
                ('valid_invaidid', models.AutoField(primary_key=True, serialize=False)),
                ('type', models.CharField(blank=True, max_length=255, null=True)),
            ],
            options={
                'managed': False,
                'db_table': 'valid_invalid',
            },
        ),
    ]
