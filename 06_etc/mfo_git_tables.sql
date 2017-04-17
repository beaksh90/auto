create table mfo_tag	       ( mfo_release_ver varchar2(30),
				mfosql_tag varchar2(30),
				mfoweb_tag varchar2(30),
				mfodg_tag varchar2(30),
				mfonp_tag varchar2(30),
				mfopg_tag varchar2(30),
				mforts_tag varchar2(30),
				mfobuild_tag varchar2(30),
				corp_info varchar2(4000),
				constraint pk_mfo_tag primary key(mfo_release_ver)
				) ;
--* XmPing�� ��������� �ʿ���� �����Ǿ� �����Ͽ���.
--* mfo_part_ver : ex) mfosql_160526.01_kor_sse : ��ǰ��_total����_(����_sub_part_���� �ʿ�� �߰�����)
--* mfo_release_ver : ex) mfo531_160526.01_exa_sse : ��ǰ��_total����_(����_sub_part_���� �ʿ�� �߰�����)
--* mfodll_tag varchar2(100), mfopjs_tag varchar2(100) �ʿ�� column add ��ɾ�� �߰�, new java pjs ��ý����̶� ������

create table corp_code    (corp_name varchar2(100),
			 corp_code varchar2(3),
			 constraint pk_mfo_corp_tag primary key(corp_code)) ;

create table runner_stat  (run_comp varchar2(15),
			 total_ver varchar2(30),
			 value number(1)
			 ) ;
-- * unit test�� ���ؼ��� unit_ver(��Ī) Į���� �߰��Ǿ�� ���� ������ ���� ���� ���忡�� ���� ����
-- * unit test�� comp�� �����ϴ�(4�ܰ� ���� �߰�) ��쿡�� lock ��� ���ؼ� runner_stat ���̺��� �ٽ� �����ؾ���. 
-- * ������ ��� �ؾ��� �� �� �𸣰���)
-- * 161028 �ذ�å�� ������ �ϳ��� vm�� cpu �� �޸𸮸� �������ְ� �ּ����� ���� ���۸� caseȭ �Ͽ� �� �� �����Ѵ�.


create table ipaddress (who varchar2(20),
             ipaddr varchar2(15),
             part varchar2(30),
             remark varchar2(4000),
             constraint uk_address unique(ipaddr,part)
             );
-- * IP Address �� ���� ���̺��̸�, Client���� ��û�Ͽ��� ��, ��ġ���� ���� �� �� �����Ѵ�.		
 
create table requirer (who varchar2(20),
             part varchar2(30),
             req_tag varchar2(10),
             mfo_release_ver varchar2(30)
             );
-- * ��û�� ���� ���� ���̺��̸�, ����, � ������ �����Ű���� �ϴ� �±� ����� �κ������� ���� ������ �ִ�.

create table mfo_tag_part(tag_info varchar2(30),
             build_ref varchar2(30),
             constraint tag_part_uk unique(tag_info)
			  );
-- * Ŀ���͸���¡�� ȯ�汸���� ���� �±׸� �����ϴ� ���̺��̴�.

create table mfo_git_comment(tag_info varchar2(30),
             hash_code varchar2(40),
			 dev_mention varchar2(4000),
             constraint git_comment_uk unique(tag_info,hash_code)
			  );
-- * release note �Ǵ� bug fix report�� ����� ���� ������ ��Ʈ ������ ���̺��̴�.