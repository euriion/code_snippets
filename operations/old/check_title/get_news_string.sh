#!/bin/bash
#ar_EG
#ar_XA
#ca_CT
#da_DK
#de_AT
#de_CH
#de_DE
#en_AA
#en_AU
#en_CA
#en_IDE
#en_IN
#en_MYE
#en_NZ
#en_PH
#en_SG
#en_UK
#en_US
#es_AR
#es_CL
#es_CO
#es_E1
#es_ES
#es_MX
#es_PE
#es_VE
#es_VZ
#fi_FI
#fr_CF
#fr_CHFR
#fr_FR
#id_ID
#it_CHIT
#it_IT
#kr_KR
#ml_MY
#nl_NL
#no_NO
#phi_PHT
#pl_PL
#pt_BR
#pt_CD
#ro_RO
#ru_RU
#sv_SE
#tai_TH
#tr_TR
#vi_VN
#zh_HK
#zh_TW

# p3
#vn br cd it chit th dk fi nl ru se no

INTLS="vi_VN pt_BR pt_CD it_IT it_CHIT tai_TH da_DK fi_FI nl_NL ru_RU sv_SE no_NO"
#TERM="common.news"
TERM="common.country"
#TERM="search.head_content.title_text"

for INTL in $INTLS; do
    echo -n $INTL
    r3 translation view vertical/$INTL $TERM
done
