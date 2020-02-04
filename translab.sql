su - oracle <<EOF1
sqlplus -s "/as sysdba" <<EOF > /tmp/tblspcchk.log
set termout off
set termout on
set serverout on size 1000000
set feedback off
spool tblspcchk.log
declare
ts_name       varchar2(40);
disk_bytes      number;
disk_max_bytes      number;
free_bytes      number;
pu   number;
HEADINGDISPLAYED        number;
percent_used  varchar2(20);
total_disk_bytes   number := 0;
total_space_alloc   number := 0;
total_space_free   number := 0;
cursor diskused is
select substr(tablespace_name,1,40), sum(bytes) db,sum(maxbytes) max_bytes
from   dba_data_files
where tablespace_name not like '%ROLL%'
group by tablespace_name;
cursor freespace is
select sum(bytes) fb
from dba_free_space
where tablespace_name = ts_name;
begin
HEADINGDISPLAYED:= 1;
open diskused;
loop
fetch diskused into ts_name, disk_bytes,disk_max_bytes;
exit when diskused%notfound;
open freespace;
fetch freespace into free_bytes;
close freespace;
if (disk_bytes >= disk_max_bytes)
then
--dbms_output.put_line(ts_name||'|'||disk_max_bytes||'|'||free_bytes);
pu := 100-(100*(free_bytes/disk_bytes));
total_disk_bytes:= total_disk_bytes + disk_bytes;
total_space_alloc:= total_space_alloc + (disk_bytes - free_bytes);
total_space_free := total_space_free + free_bytes;
else
total_disk_bytes:= total_disk_bytes + disk_max_bytes;
total_space_alloc:= total_space_alloc + (disk_bytes - free_bytes);
total_space_free := total_space_free + (disk_max_bytes - (disk_bytes - free_bytes));
pu:=100-(100*(total_space_free/total_disk_bytes));
end if;


if pu >= 50 then
percent_used:= to_char(pu, '999');
end if;

if (pu >= 50) then
if (HEADINGDISPLAYED != 0) then
HEADINGDISPLAYED:= 0;
dbms_output.put_line ('  ');
dbms_output.put_line (
rpad('Tablespace Name', 22)||
rpad('Disk Used', 14)||
rpad('Space Alloc', 15)||
rpad('Free Space', 13)||
'Percent Used'
);
dbms_output.put_line (
lpad ('-', 20, '-')||' '||
lpad ('-', 12, '-')||' '||
lpad ('-', 12, '-')||'   '||
lpad ('-', 10, '-')||'   '||
lpad ('-', 17, '-')
);
end if;
end if;
if pu >= 50  then
dbms_output.put_line(
rpad(ts_name, 20)||
to_char(total_disk_bytes, '99999,999,999')||' '||
to_char (disk_bytes-free_bytes) ||' '||
to_char(total_space_free, '9999,999,999')||'   '||
percent_used
);
end if;
end loop;
close diskused;
if (HEADINGDISPLAYED != 1) then
dbms_output.put_line(
lpad ('-', 20, '-')||' '||
lpad ('-', 12, '-')||' '||
lpad ('-', 12, '-')||'   '||
lpad ('-', 10, '-')||'   '||
lpad ('-', 17, '-')
);
end if;
end;
/
spool off
EOF
EOF1
