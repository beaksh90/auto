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
-- * 161028 해결책이 보였음 하나의 vm에 cpu 및 메모리를 몰빵해주고 최소한의 빌드 동작만 case화 하여 명세 및 실행한다.


create table ipaddress (who varchar2(20),
             ipaddr varchar2(15),
             part varchar2(30),
             remark varchar2(4000),
             constraint uk_address unique(ipaddr,part)
             );
-- * IP Address 에 관한 테이블이며, Client에서 요청하였을 때, 설치파일 전달 할 때 참조한다.		
 
create table requirer (who varchar2(20),
             part varchar2(30),
             req_tag varchar2(10),
             mfo_release_ver varchar2(30)
             );
-- * 요청에 대한 정보 테이블이며, 누가, 어떤 파일을 변경시키고자 하는 태그 어느쪽 부분인지에 대한 정보가 있다.

create table mfo_tag_part(tag_info varchar2(30),
             build_ref varchar2(30),
             constraint tag_part_uk unique(tag_info)
			  );
-- * 커스터마이징한 환경구성을 위해 태그를 저장하는 테이블이다.

create table mfo_git_comment(tag_info varchar2(30),
             hash_code varchar2(40),
			 dev_mention varchar2(4000),
             constraint git_comment_uk unique(tag_info,hash_code)
			  );
-- * release note 또는 bug fix report를 만들기 위한 개발자 멘트 수집용 테이블이다.