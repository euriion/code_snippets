# ===============================================
# NDAP feeding configuration
# -----------------------------------------------
# maintainer: aiden.hong@kt.com
# create: 2012-11-20
# copyright: NexR (KTcloudware)
# -----------------------------------------------
# **attention**
#   DO NOT modify without confirmation
# ===============================================

feed_dir:
  hdfs_base_dir: '/nstep/dev/rawdata'
  local_base_dir: '/data/rawdata'
hadoop:
  home_path: '/home/csipc/ndap/modules/hadoop'
hive:
  server:
    ipaddress: '172.27.64.45'
    port: 10000
  target_database: 'nstep_dev'
databases:
  nstep_dev:
    tables:
      RAW_ACCESS_TRL_LOG_INFO:
        feed:
          enable: Yes
          overwrite: Yes
        description: "조회로그?"
        hdfs_base_dir: "/nstep_dev/rawdata"
        template_feed_filename: "%(year)s%(month)s%(day)s.csv"
        pattern_feed_filename: "([0-9]{4,4})([0-9]{2,2})([0-9]{2,2}).csv"
        local_dir: '/data/rawdata/ACCESS_TRL_LOG_INFO/temp'
        location: '/nstep_dev/rawdata/ACCESS_TRL_LOG_INFO'
        external: Yes
        file_type: TEXTFILE
        line_delimiter: '\n'
        field_delimiter: ','
        fields:
#          - ['SVC_CNTR_NO',       'string']
          - ['SVC_NO',            'string']
          - ['CUST_IDNT_NO',      'string']
          - ['CUST_NO',           'int']
          - ['BILL_ACNT_NO',      'int']
          - ['SCRN_ID',           'string']
          - ['LOG_DT',            'string']
          - ['SYST_ID',           'string']
          - ['LOG_IND_CD',        'string']
          - ['USER_ID',           'string']
          - ['ORGN_ID',           'string']
          - ['SVC_ID',            'string']
          - ['OPERATION_ID',      'string']
          - ['INQR_TOKEN_ID',     'string']
          - ['PROTOCOL_IP',       'string']
          - ['HEADER_IP',         'string']
          - ['ACCESS_TRL_IND_CD', 'string']
        partition_keys:
          - ['idx_year', 'string', '%(year)s']
          - ['idx_month', 'string', '%(month)s']
          - ['idx_day', 'string', '%(day)s']
          - ['LOG_DATE', 'string', '%(year)s%(month)s%(day)s']
      RAW_CUST_INFO_INQR_LOG_INFO:
        feed:
          enable: Yes
          overwrite: Yes
        description: "고객조회로그"
        hdfs_base_dir: "/nstep_dev/rawdata"
        template_feed_filename: "%(year)s%(month)s%(day)s.csv"
        pattern_feed_filename: "([0-9]{4,4})([0-9]{2,2})([0-9]{2,2}).csv"
        local_dir: "/data/rawdata/CUST_INFO_INQR_LOG_INFO"
        location: '/nstep_dev/rawdata/CUST_INFO_INQR_LOG_INFO'
        external: Yes
        file_type: TEXTFILE
        line_delimiter: '\n'
        field_delimiter: ','
        fields:
          - ['SVC_CNTR_NO',       'string']
          - ['SVC_NO',            'string']
          - ['CUST_IDNT_NO',      'string']
          - ['CUST_NO',           'int']
          - ['BILL_ACNT_NO',      'int']
          - ['SCRN_ID',           'string']
          - ['LOG_DT',            'string']
          - ['SYST_ID',           'string']
          - ['LOG_IND_CD',        'string']
          - ['USER_ID',           'string']
          - ['ORGN_ID',           'string']
          - ['SVC_ID',            'string']
          - ['OPERATION_ID',      'string']
          - ['INQR_TOKEN_ID',     'string']
          - ['PROTOCOL_IP',       'string']
          - ['HEADER_IP',         'string']
          - ['ACCESS_TRL_IND_CD', 'string']
        partition_keys:
          - ['idx_year', 'string', '%(year)s']
          - ['idx_month', 'string', '%(month)s']
          - ['idx_day', 'string', '%(day)s']
          - ['LOG_DATE', 'string', '%(year)s%(month)s%(day)s']
      RAW_CUST_INFO_INQR_LOG_INFO_UM:
        feed:
          enable: Yes
          overwrite: Yes
        description: "고객조회마스킹해제로그"
        hdfs_base_dir: "/nstep_dev/rawdata"
        template_feed_filename: "UM_%(year)s%(month)s%(day)s.csv"
        pattern_feed_filename: "UM_([0-9]{4,4})([0-9]{2,2})([0-9]{2,2}).csv"
        local_dir: '/data/rawdata/CUST_INFO_INQR_LOG_INFO_UM'
        location: '/nstep_dev/rawdata/CUST_INFO_INQR_LOG_INFO_UM'
        external: Yes
        file_type: TEXTFILE
        line_delimiter: '\n'
        field_delimiter: ','
        fields:
          - ['SVC_CNTR_NO',       'string']
          - ['SVC_NO',            'string']
          - ['CUST_IDNT_NO',      'string']
          - ['CUST_NO',           'int']
          - ['BILL_ACNT_NO',      'int']
          - ['SCRN_ID',           'string']
          - ['LOG_DT',            'string']
          - ['SYST_ID',           'string']
          - ['LOG_IND_CD',        'string']
          - ['USER_ID',           'string']
          - ['ORGN_ID',           'string']
          - ['SECUR_ITEM_NO',     'int']
          - ['COM_ID',            'string']
          - ['SVC_ID',            'string']
          - ['OPERATION_ID',      'string']
          - ['INQR_TOKEN_ID',     'string']
          - ['PROTOCOL_IP',       'string']
          - ['HEADER_IP',         'string']
          - ['ACCESS_TRL_IND_CD', 'string']
        partition_keys:
          - ['idx_year', 'string', '%(year)s']
          - ['idx_month', 'string', '%(month)s']
          - ['idx_day', 'string', '%(day)s']
          - ['LOG_DATE', 'string', '%(year)s%(month)s%(day)s']

#sub directory
#BLCK_LOG_INFO : 차단로그
#CRCL_ORGN_INFO : 조직정보
#CRCL_ORGN_RLTN_HIST : 조직관계변경내역
#CUST_INFO_INQR_LOG_INFO : 고객조회
#CUST_INFO_INQR_LOG_INFO_UM : 고객조회 마스킹해제
#USER_ORGN_INFO : 사용자조직정보
#WRKJOB_ACTRSL_DD_SUM : 영업실적
#Jennifer/* : 제니퍼
#ACCESS_TRL_LOG_INFO : 접근로그