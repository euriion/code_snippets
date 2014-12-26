-- "GET /delivery/wfr.php?zoneid=18485&cb=1996448306&category=N_9902&loc=http%3A%2F%2Fad.ad4989.co.kr%2Fcgi-bin%2FPelicanc.dll%3Fimpr%3Fpageid%3D00PZ%26slot%3D1%2C0%26nowdt%3D1419302057176%26out%3Diframe&referer=http%3A%2F%2Fwww.soccerline.co.kr%2Fslboard%2Fview.php%3Fuid%3D1988572216%26page%3D1%26code%3Dsoccerboard%26keyfield%3D%26key%3D%26period%3D&title=&passback=http%3A%2F%2Fad.ilikesponsorad.co.kr%2Fad%2Fui%2Fad_live.html%3Fpcs%3DUTF-8%26prf%3Dhttp%253A%252F%252Fwww.soccerline.co.kr%252Fslboard%252Fview.php%253Fuid%253D1988572216%2526page%253D1%2526code%253Dsoccerboard%2526keyfield%253D%2526key%253D%2526period%253D%26plt%3Dhttp%253A%252F%252Fad.ad4989.co.kr%252Fcgi-bin%252FPelicanc.dll%253Fimpr%253Fpageid%253D00PZ%2526slot%253D1%252C0%2526nowdt%253D1419302057176%2526out%253Diframe%26pvu%3DPVU_5498d4a9e9ada%26pvn%3D1%26stu%3DSTU_547b1f4ade096%26wid%3D300%26hei%3D250%26aimc%3D9902%26apu%3D%26ct%3DN%26ctb%3DN%26ctbp%3DN%26gadx%3DN%26cm2%3DN%26wp%3DN%26ebay%3DY%26ntss%3DY%26nts%3DY HTTP/1.1"

-- two phase type
select a.script_name as script_name from (
select regexp_extract(dummy, "^\"GET /delivery/([^\?]*)\?.*", 1) as script_name 
from dual) a
where array_contains(array(cast("wfr.php" as string), cast("wjs.php" as string), cast("wpc.php" as string)), a.script_name)


-- one phase type
select regexp_extract(dummy, "^\"GET /delivery/([^\?]*)\?.*", 1) as script_name 
from dual
where array_contains(array(cast("wfr.php" as string), cast("wjs.php" as string), cast("wpc.php" as string)), regexp_extract(dummy, "^\"GET /delivery/([^\?]*)\?.*", 1))

