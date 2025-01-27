# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2018-06-28 14:47
from __future__ import unicode_literals

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('CentralMI', '0005_fielddetail_filteroption'),
    ]

    operations = [
        migrations.CreateModel(
            name='Errorlog',
            fields=[
                ('error_id', models.AutoField(primary_key=True, serialize=False)),
                ('errorlog_date', models.DateTimeField(default=datetime.datetime(2018, 6, 28, 20, 17, 53, 35771))),
                ('error_occurancedate', models.DateTimeField(default=datetime.datetime(2018, 6, 28, 20, 17, 53, 35771))),
                ('error_reportedby', models.CharField(max_length=50)),
                ('error_reportedteam', models.CharField(max_length=50)),
                ('error_description', models.TextField()),
            ],
            options={
                'db_table': 'errorlog',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='Errortype',
            fields=[
                ('error_typeid', models.AutoField(primary_key=True, serialize=False)),
                ('error_type', models.CharField(max_length=50)),
            ],
            options={
                'db_table': 'errortype',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='Feedback',
            fields=[
                ('feedback_id', models.AutoField(primary_key=True, serialize=False)),
                ('feedback_date', models.DateTimeField(default=datetime.datetime(2018, 6, 28, 20, 17, 53, 36267))),
                ('feedback_integer', models.IntegerField(blank=True, null=True)),
                ('feedback_text', models.CharField(blank=True, max_length=255, null=True)),
                ('feedback_datetime', models.DateTimeField(blank=True, null=True)),
            ],
            options={
                'db_table': 'feedback',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='FeedbackQuestion',
            fields=[
                ('feedback_questionid', models.AutoField(primary_key=True, serialize=False)),
                ('feedback_questiondate', models.DateTimeField(default=datetime.datetime(2018, 6, 28, 20, 17, 53, 37259))),
                ('feedback_question', models.CharField(max_length=255)),
                ('feedback_answerdatatype', models.CharField(max_length=255)),
            ],
            options={
                'db_table': 'feedback_question',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='OtDetail',
            fields=[
                ('ot_id', models.AutoField(primary_key=True, serialize=False)),
                ('ot_startdatetime', models.DateTimeField(default=datetime.datetime(2018, 6, 28, 20, 17, 53, 37755))),
                ('ot_enddatetime', models.DateTimeField(default=datetime.datetime(2018, 6, 28, 20, 17, 53, 37755))),
                ('ot_hrs', models.IntegerField(blank=True, null=True)),
            ],
            options={
                'db_table': 'ot_detail',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='OtStatus',
            fields=[
                ('ot_statusid', models.AutoField(primary_key=True, serialize=False)),
                ('ot_status', models.CharField(max_length=50)),
            ],
            options={
                'db_table': 'ot_status',
                'managed': False,
            },
        ),
        migrations.CreateModel(
            name='ReportType',
            fields=[
                ('report_typid', models.AutoField(primary_key=True, serialize=False)),
                ('report_type', models.CharField(max_length=255)),
            ],
            options={
                'db_table': 'report_type',
                'managed': False,
            },
        ),
    ]
