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
--* XmPing은 형상관리가 필요없다 생각되어 제외하였음.
--* mfo_part_ver : ex) mfosql_160526.01_kor_sse : 제품군_total버전_(국가_sub_part_고객사 필요시 추가기재)
--* mfo_release_ver : ex) mfo531_160526.01_exa_sse : 제품군_total버전_(국가_sub_part_고객사 필요시 추가기재)
--* mfodll_tag varchar2(100), mfopjs_tag varchar2(100) 필요시 column add 명령어로 추가, new java pjs 출시시점이라 제외함

create table corp_code    (corp_name varchar2(100),
			 corp_code varchar2(3),
			 constraint pk_mfo_corp_tag primary key(corp_code)) ;

create table runner_stat  (run_comp varchar2(15),
			 total_ver varchar2(30),
			 value number(1)
			 ) ;
-- * unit test를 위해서는 unit_ver(가칭) 칼럼이 추가되어야 하지 않을까 당장 통합 빌드에는 문제 없음
-- * unit test와 comp만 변경하는(4단계 추후 추가) 경우에는 lock 제어를 위해서 runner_stat 테이블을 다시 수정해야함. 
-- * 지금은 어떻게 해야할 지 잘 모르겠음)