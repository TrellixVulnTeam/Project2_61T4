# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2018-10-02 15:30
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('CentralMI', '0019_tblusefullinks'),
    ]

    operations = [
        migrations.CreateModel(
            name='AssignView',
            fields=[
                ('viewassign_id', models.AutoField(primary_key=True, serialize=False)),
            ],
            options={
                'db_table': 'assign_view',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TblNavbarView',
            fields=[
                ('navbar_id', models.AutoField(primary_key=True, serialize=False)),
            ],
            options={
                'db_table': 'tbl_navbar_view',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='TeamMetricsData',
            fields=[
                ('metrics_id', models.AutoField(primary_key=True, serialize=False)),
                ('date_time', models.DateTimeField()),
                ('total', models.IntegerField(blank=True, db_column='Total', null=True)),
                ('wip', models.IntegerField(blank=True, db_column='WIP', null=True)),
                ('uat', models.IntegerField(blank=True, db_column='UAT', null=True)),
                ('completed', models.IntegerField(blank=True, db_column='Completed', null=True)),
                ('project', models.IntegerField(blank=True, db_column='Project', null=True)),
            ],
            options={
                'db_table': 'team_metrics_data',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='ViewType',
            fields=[
                ('view_id', models.AutoField(primary_key=True, serialize=False)),
                ('viewname', models.CharField(blank=True, max_length=255, null=True)),
            ],
            options={
                'db_table': 'view_type',
                'managed': False,
            },
        ),
    ]