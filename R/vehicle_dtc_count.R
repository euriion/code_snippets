#===================================================================#
#                   description: aggregation                        #
#                   date: 2013.06.14                                #
#                   name: Andrew                                    #
#                   package: RHive                                  #
#===================================================================#



library(RHive)

rhive.connect("10.10.189.120", 10001)  # RHive connection
rhive.use.database("poc2")  # poc databases

rhive.show.tables()

# table description
rhive.desc.table("vcrm_northam_carmaster_data_dtc")
rhive.desc.table("vcrm_northam_fault_desc_dtc")
rhive.desc.table("vcrm_tms_northam_dtc")
rhive.desc.table("vcrm_weather")

# table description
rhive.query("select * from vcrm_northam_carmaster_data_dtc limit 10")
rhive.query("select * from vcrm_northam_fault_desc_dtc limit 10") 
rhive.query("select * from vcrm_tms_northam_dtc limit 10")
rhive.query("select * from vcrm_weather limit 10")

# table description
rhive.query("select count(*) from vcrm_northam_carmaster_data_dtc")
rhive.query("select count(*) from vcrm_northam_fault_desc_dtc") 
rhive.query("select count(*) from vcrm_tms_northam_dtc")
rhive.query("select count(*) from vcrm_weather")

# - record: 6613064, variable: 13
# vcrm_northam_fault_desc_dtc - record: 3030, variable: 4
# vcrm_tms_northam_dtc - record: 4958181, variable: 16
# vcrm_weather - record: 133980, variable: 73

# factor count: vcrm_tms_northam_dtc table
# naming: vcrm_tms_northam_dtc table -> vtnd
rhive.query("select count(distinct session_ic) from vcrm_tms_northam_dtc") # 33494687
rhive.query("select count(distinct vin) from vcrm_tms_northam_dtc") # 543607
rhive.query("select count(distinct session_start_datetime) from vcrm_tms_northam_dtc") # 710566
rhive.query("select count(distinct dtc_code) from vcrm_tms_northam_dtc") # 567
rhive.query("select count(distinct dtc_system) from vcrm_tms_northam_dtc") # 7
rhive.query("select count(distinct dtc_sub_system) from vcrm_tms_northam_dtc") # 17
rhive.query("select count(distinct measure_breakdown_code) from vcrm_tms_northam_dtc") # 29
rhive.query("select count(distinct breakdown_dtc_code) from vcrm_tms_northam_dtc") # 689
rhive.query("select count(distinct dtc_originated_mileage) from vcrm_tms_northam_dtc") # 44792
rhive.query("select count(distinct dtc_originated_datetime) from vcrm_tms_northam_dtc") # 701240
rhive.query("select count(distinct mil_on_ind) from vcrm_tms_northam_dtc") # 2
rhive.query("select count(distinct odometer_dtc_ind) from vcrm_tms_northam_dtc") # 2
rhive.query("select count(distinct created_date) from vcrm_tms_northam_dtc") # 137705
rhive.query("select count(distinct service_type_name) from vcrm_tms_northam_dtc") # 4

# frequncy table
vtnd.session_ic_fq               <- rhive.query("select session_ic, count(*) from vcrm_tms_northam_dtc group by session_ic")
vtnd.vin_fq                      <- rhive.query("select vin, count(*) from vcrm_tms_northam_dtc group by vin")
# vtnd.session_start_datetime_fq   <- rhive.query("select session_start_datetime, count(*) from vcrm_tms_northam_dtc group by session_start_datetime")
vtnd.dtc_code_fq                 <- rhive.query("select dtc_code, count(*) from vcrm_tms_northam_dtc group by dtc_code")
vtnd.dtc_sysem_fq                <- rhive.query("select dtc_system, count(*) from vcrm_tms_northam_dtc group by dtc_system")
vtnd.dtc_sub_sysem_fq            <- rhive.query("select dtc_sub_system, count(*) from vcrm_tms_northam_dtc group by dtc_sub_system")
vtnd.measure_breakdown_code_fq   <- rhive.query("select measure_breakdown_code, count(*) from vcrm_tms_northam_dtc group by measure_breakdown_code")
vtnd.breakdown_dtc_code_fq       <- rhive.query("select breakdown_dtc_code, count(*) from vcrm_tms_northam_dtc group by breakdown_dtc_code")
vtnd.dtc_originated_mileage_fq   <- rhive.query("select dtc_originated_mileage, count(*) from vcrm_tms_northam_dtc group by dtc_originated_mileage")
# vtnd.dtc_originated_datetime_fq  <- rhive.query("select dtc_originated_datetime, count(*) from vcrm_tms_northam_dtc group by dtc_originated_datetime")
vtnd.mil_on_ind_fq               <- rhive.query("select mil_on_ind, count(*) from vcrm_tms_northam_dtc group by mil_on_ind")
vtnd.odometer_dtc_ind_fq         <- rhive.query("select odometer_dtc_ind, count(*) from vcrm_tms_northam_dtc group by odometer_dtc_ind")
# vtnd.created_date_fq             <- rhive.query("select created_date, count(*) from vcrm_tms_northam_dtc group by created_date")
vtnd.service_type_name_fq        <- rhive.query("select service_type_name, count(*) from vcrm_tms_northam_dtc group by service_type_name")




# factor count: vcrm_northam_fault_desc_dtc table
# naming: vcrm_northam_fault_desc_dtc table -> vnfdd
rhive.query("select count(distinct dtc_cd) from vcrm_northam_fault_desc_dtc") # 3030
rhive.query("select count(distinct dtc_cd_expl_sbc) from vcrm_northam_fault_desc_dtc") # 2993
rhive.query("select count(distinct etl_cer_dmt) from vcrm_northam_fault_desc_dtc") # 
rhive.query("select count(distinct etl_mdfy_dmt) from vcrm_northam_fault_desc_dtc") # 

# frequncy table
vnfdd.dtc_cd_fq            <- rhive.query("select dtc_cd, count(*) from vcrm_northam_fault_desc_dtc group by dtc_cd")
vnfdd.dtc_cd_expl_sbc_fq   <- rhive.query("select dtc_cd_expl_sbc, count(*) from vcrm_northam_fault_desc_dtc group by dtc_cd_expl_sbc")
vnfdd.etl_cer_dmt_fq       <- rhive.query("select etl_cer_dmt, count(*) from vcrm_northam_fault_desc_dtc group by etl_cer_dmt")
vnfdd.etl_mdfy_dmt_fq      <- rhive.query("select etl_mdfy_dmt, count(*) from vcrm_northam_fault_desc_dtc group by etl_mdfy_dmt")





# factor count: vcrm_northam_carmaster_data_dtc table
# naming: vcrm_northam_carmaster_data_dtc table -> vncdd
rhive.query("select count(distinct vin) from vcrm_northam_carmaster_data_dtc") # 6613064
rhive.query("select count(distinct vin_srz_cd) from vcrm_northam_carmaster_data_dtc") # 18
rhive.query("select count(distinct vin_y) from vcrm_northam_carmaster_data_dtc") # 22
rhive.query("select count(distinct vin_trim_cd) from vcrm_northam_carmaster_data_dtc") # 11
rhive.query("select count(distinct vrm_subj_car_yn) from vcrm_northam_carmaster_data_dtc") # 2
rhive.query("select count(distinct prdn_dt) from vcrm_northam_carmaster_data_dtc") # 6460
rhive.query("select count(distinct sale_dt) from vcrm_northam_carmaster_data_dtc") # 7477
rhive.query("select count(distinct vin_tm_cd) from vcrm_northam_carmaster_data_dtc") # 3
rhive.query("select count(distinct qm_vehl_cd) from vcrm_northam_carmaster_data_dtc") # 32
rhive.query("select count(distinct trim_l_cd_expl_sbc) from vcrm_northam_carmaster_data_dtc") # 99
rhive.query("select count(distinct tm_type_nm) from vcrm_northam_carmaster_data_dtc") # 12
rhive.query("select count(distinct dir_reg) from vcrm_northam_carmaster_data_dtc") # 60
rhive.query("select count(distinct eng_cd_expl_sbc) from vcrm_northam_carmaster_data_dtc") # 28

# frequncy table
vncdd.vin_fq                   <- rhive.query("select vin, count(*) from vcrm_northam_carmaster_data_dtc group by vin")
vncdd.vin_srz_cd_fq            <- rhive.query("select vin_srz_cd, count(*) from vcrm_northam_carmaster_data_dtc group by vin_srz_cd")
vncdd.vin_y_fq                 <- rhive.query("select vin_y, count(*) from vcrm_northam_carmaster_data_dtc group by vin_y")
vncdd.vin_trim_cd_fq           <- rhive.query("select vin_trim_cd, count(*) from vcrm_northam_carmaster_data_dtc group by vin_trim_cd")
vncdd.vrm_subj_car_yn_fq       <- rhive.query("select vrm_subj_car_yn, count(*) from vcrm_northam_carmaster_data_dtc group by vrm_subj_car_yn")
vncdd.prdn_dt_fq               <- rhive.query("select prdn_dt, count(*) from vcrm_northam_carmaster_data_dtc group by prdn_dt")
vncdd.sale_dt_fq               <- rhive.query("select sale_dt, count(*) from vcrm_northam_carmaster_data_dtc group by sale_dt")
vncdd.vin_tm_cd_fq             <- rhive.query("select vin_tm_cd, count(*) from vcrm_northam_carmaster_data_dtc group by vin_tm_cd")
vncdd.qm_vehl_cd_fq            <- rhive.query("select qm_vehl_cd, count(*) from vcrm_northam_carmaster_data_dtc group by qm_vehl_cd")
vncdd.trim_l_cd_expl_sbc_fq    <- rhive.query("select trim_l_cd_expl_sbc, count(*) from vcrm_northam_carmaster_data_dtc group by trim_l_cd_expl_sbc")
vncdd.tm_type_nm_fq            <- rhive.query("select tm_type_nm, count(*) from vcrm_northam_carmaster_data_dtc group by tm_type_nm")
vncdd.dir_reg_fq               <- rhive.query("select dir_reg, count(*) from vcrm_northam_carmaster_data_dtc group by dir_reg")
vncdd.eng_cd_expl_sbc_fq       <- rhive.query("select eng_cd_expl_sbc, count(*) from vcrm_northam_carmaster_data_dtc group by eng_cd_expl_sbc")


