
select tbl.*,r.*, st.create_date,st.modify_date,isnull(pk.constraint_name,'No Primary Key') as [PK],
isnull(substring(fk.Fkeys,2,len(fk.Fkeys)),'No Foreign Key') as [FK] 
from  sys.tables st
inner join 
(
select t.name as tableName ,t.object_id, s.name ,count(c.object_id) as NoOfColumns
from 
  sys.tables t inner join sys.schemas s on t.schema_id=s.schema_id
  inner join sys.columns c on t.object_id=c.object_id
  group by  t.name,t.object_id, s.name
--  order by t.name
) tbl on st.object_id=tbl.object_id
inner join 
(select object_id,sum(rows) as NoOfRows from  sys.partitions p group by object_id) r
on tbl.object_id=r.object_id
left outer join
(select table_name,constraint_name, table_schema from information_schema.table_constraints where constraint_type = 'PRIMARY KEY') pk
 on pk.table_name=st.name and tbl.name=pk.table_schema
left outer join
(
SELECT distinct 
      table_name, table_schema 
    , (
        SELECT N', ' + CAST(constraint_name AS VARCHAR(1255))
        FROM information_schema.table_constraints f2
        WHERE f1.table_name = f2.table_name and constraint_type = 'FOREIGN KEY'
        FOR XML PATH ('')) AS Fkeys
FROM information_schema.table_constraints f1 where  constraint_type = 'FOREIGN KEY'
) fk
 on fk.table_name=st.name and tbl.name=fk.table_schema
--where NoOfRows=0
order by st.name