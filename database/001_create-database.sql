drop table if exists running.experts;

CREATE TABLE running.experts (
	report_id varchar(100) NOT NULL,
	report_result_id varchar(100) NOT NULL,
	status varchar(100) NOT NULL,
	container_id varchar(100) NULL,
	server_id varchar(100) NULL,
	container_status varchar(100) NOT NULL,
	created timestamp NOT NULL,
	first_started timestamp NULL,
	last_started timestamp NULL,
	last_heartbeat timestamp NULL,
	CONSTRAINT experts_pk PRIMARY KEY (report_id,report_result_id)
);
