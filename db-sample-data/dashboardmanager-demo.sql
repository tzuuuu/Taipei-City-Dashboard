--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO postgres;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO postgres;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_chatlog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ai_chatlog (
    id bigint NOT NULL,
    session_id character varying(100) NOT NULL,
    user_id character varying(100),
    provider character varying(50) DEFAULT 'twcc'::character varying NOT NULL,
    model character varying(100),
    question text NOT NULL,
    answer text,
    tool_used boolean DEFAULT false,
    tools jsonb,
    input_tokens bigint DEFAULT 0,
    output_tokens bigint DEFAULT 0,
    total_tokens bigint DEFAULT 0,
    latency_ms bigint,
    status character varying(30) DEFAULT 'success'::character varying NOT NULL,
    error_code character varying(100),
    error_message text,
    ip_address character varying(45) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ai_chatlog OWNER TO postgres;

--
-- Name: ai_chatlog_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ai_chatlog_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_chatlog_id_seq OWNER TO postgres;

--
-- Name: ai_chatlog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ai_chatlog_id_seq OWNED BY public.ai_chatlog.id;


--
-- Name: auth_user_group_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_group_roles (
    auth_user_id bigint NOT NULL,
    group_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE public.auth_user_group_roles OWNER TO postgres;

--
-- Name: auth_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_users (
    id bigint NOT NULL,
    name character varying,
    email character varying,
    password character varying,
    idno character varying,
    uuid character varying,
    tp_account character varying,
    member_type character varying,
    verify_level character varying,
    is_admin boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_whitelist boolean DEFAULT false,
    is_blacked boolean DEFAULT false,
    expired_at timestamp with time zone,
    created_at timestamp with time zone,
    login_at timestamp with time zone,
    CONSTRAINT chk_auth_users_email CHECK (((email)::text ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'::text))
);


ALTER TABLE public.auth_users OWNER TO postgres;

--
-- Name: auth_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auth_users_id_seq OWNER TO postgres;

--
-- Name: auth_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_users_id_seq OWNED BY public.auth_users.id;


--
-- Name: chat_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_logs (
    id bigint NOT NULL,
    session text,
    question text,
    answer text,
    ip_address character varying(45) NOT NULL,
    user_id bigint,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.chat_logs OWNER TO postgres;

--
-- Name: chat_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_logs_id_seq OWNER TO postgres;

--
-- Name: chat_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_logs_id_seq OWNED BY public.chat_logs.id;


--
-- Name: component_charts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.component_charts (
    index character varying NOT NULL,
    color character varying[],
    types character varying[],
    unit character varying
);


ALTER TABLE public.component_charts OWNER TO postgres;

--
-- Name: component_maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.component_maps (
    id bigint NOT NULL,
    index character varying NOT NULL,
    title character varying NOT NULL,
    type character varying NOT NULL,
    source character varying NOT NULL,
    size character varying,
    icon character varying,
    paint json,
    property json
);


ALTER TABLE public.component_maps OWNER TO postgres;

--
-- Name: component_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.component_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.component_maps_id_seq OWNER TO postgres;

--
-- Name: component_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.component_maps_id_seq OWNED BY public.component_maps.id;


--
-- Name: components; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.components (
    id bigint NOT NULL,
    index character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.components OWNER TO postgres;

--
-- Name: components_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.components_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.components_id_seq OWNER TO postgres;

--
-- Name: components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.components_id_seq OWNED BY public.components.id;


--
-- Name: contributors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contributors (
    id bigint NOT NULL,
    user_id character varying NOT NULL,
    user_name character varying NOT NULL,
    image text,
    link text NOT NULL,
    identity character varying,
    description text,
    include boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.contributors OWNER TO postgres;

--
-- Name: contributors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contributors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contributors_id_seq OWNER TO postgres;

--
-- Name: contributors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contributors_id_seq OWNED BY public.contributors.id;


--
-- Name: dashboard_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dashboard_groups (
    dashboard_id bigint NOT NULL,
    group_id bigint NOT NULL
);


ALTER TABLE public.dashboard_groups OWNER TO postgres;

--
-- Name: dashboards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dashboards (
    id bigint NOT NULL,
    index character varying NOT NULL,
    name character varying NOT NULL,
    components integer[],
    icon text,
    updated_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.dashboards OWNER TO postgres;

--
-- Name: dashboards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dashboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dashboards_id_seq OWNER TO postgres;

--
-- Name: dashboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dashboards_id_seq OWNED BY public.dashboards.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying,
    is_personal boolean DEFAULT false,
    create_by bigint
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_id_seq OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incidents (
    id bigint NOT NULL,
    type text,
    description text,
    distance numeric,
    latitude numeric,
    longitude numeric,
    place text,
    "time" timestamp with time zone,
    status text
);


ALTER TABLE public.incidents OWNER TO postgres;

--
-- Name: incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incidents_id_seq OWNER TO postgres;

--
-- Name: incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incidents_id_seq OWNED BY public.incidents.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.issues (
    id bigint NOT NULL,
    title character varying NOT NULL,
    user_name character varying NOT NULL,
    user_id character varying NOT NULL,
    context text,
    description text NOT NULL,
    decision_desc text,
    status character varying NOT NULL,
    updated_by character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.issues OWNER TO postgres;

--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.issues_id_seq OWNER TO postgres;

--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.issues_id_seq OWNED BY public.issues.id;


--
-- Name: query_charts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.query_charts (
    index character varying NOT NULL,
    history_config json,
    map_config_ids integer[],
    map_filter json,
    time_from character varying,
    time_to character varying,
    update_freq integer,
    update_freq_unit character varying,
    source character varying,
    short_desc text,
    long_desc text,
    use_case text,
    links text[],
    contributors text[],
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    query_type character varying,
    query_chart text,
    query_history text,
    city text NOT NULL
);


ALTER TABLE public.query_charts OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying,
    access_control boolean DEFAULT false,
    modify boolean DEFAULT false,
    read boolean DEFAULT false
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: view_points; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.view_points (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    center_x numeric,
    center_y numeric,
    zoom numeric,
    pitch numeric,
    bearing numeric,
    name text,
    point_type text
);


ALTER TABLE public.view_points OWNER TO postgres;

--
-- Name: view_points_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.view_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.view_points_id_seq OWNER TO postgres;

--
-- Name: view_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.view_points_id_seq OWNED BY public.view_points.id;


--
-- Name: ai_chatlog id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_chatlog ALTER COLUMN id SET DEFAULT nextval('public.ai_chatlog_id_seq'::regclass);


--
-- Name: auth_users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users ALTER COLUMN id SET DEFAULT nextval('public.auth_users_id_seq'::regclass);


--
-- Name: chat_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_logs ALTER COLUMN id SET DEFAULT nextval('public.chat_logs_id_seq'::regclass);


--
-- Name: component_maps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component_maps ALTER COLUMN id SET DEFAULT nextval('public.component_maps_id_seq'::regclass);


--
-- Name: components id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.components ALTER COLUMN id SET DEFAULT nextval('public.components_id_seq'::regclass);


--
-- Name: contributors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contributors ALTER COLUMN id SET DEFAULT nextval('public.contributors_id_seq'::regclass);


--
-- Name: dashboards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboards ALTER COLUMN id SET DEFAULT nextval('public.dashboards_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: incidents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents ALTER COLUMN id SET DEFAULT nextval('public.incidents_id_seq'::regclass);


--
-- Name: issues id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issues ALTER COLUMN id SET DEFAULT nextval('public.issues_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: view_points id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.view_points ALTER COLUMN id SET DEFAULT nextval('public.view_points_id_seq'::regclass);


--
-- Data for Name: ai_chatlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ai_chatlog (id, session_id, user_id, provider, model, question, answer, tool_used, tools, input_tokens, output_tokens, total_tokens, latency_ms, status, error_code, error_message, ip_address, created_at) FROM stdin;
\.


--
-- Data for Name: auth_user_group_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user_group_roles (auth_user_id, group_id, role_id) FROM stdin;
1	4	1
1	1	1
1	2	1
1	3	1
6	5	1
6	1	1
6	2	1
6	3	1
\.


--
-- Data for Name: auth_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_users (id, name, email, password, idno, uuid, tp_account, member_type, verify_level, is_admin, is_active, is_whitelist, is_blacked, expired_at, created_at, login_at) FROM stdin;
1	admin	seed-admin@gmail.com	8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918	\N	\N	\N	\N	\N	t	t	t	f	\N	2026-04-28 03:12:29.252503+00	2026-04-29 15:38:33.551874+00
6	admin	admin@gmail.com	8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918	\N	\N	\N	\N	\N	t	t	t	f	\N	2026-04-30 05:29:59.022851+00	2026-04-30 05:29:59.022851+00
\.


--
-- Data for Name: chat_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_logs (id, session, question, answer, ip_address, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: component_charts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.component_charts (index, color, types, unit) FROM stdin;
youbike_availability	{#9DC56E,#356340,#9DC56E}	{GuageChart,BarPercentChart}	輛
ebus_percent	{#9DC56E,#356340,#9DC56E}	{IconPercentChart,BarPercentChart}	輛
city_age_distribution	{#24B0DD,#56B96D,#F8CF58,#F5AD4A,#E170A6,#ED6A45,#AF4137,#10294A}	{DistrictChart,ColumnChart}	仟人
dependency_aging	{#67baca,#fbf3ac}	{ColumnLineChart,TimelineSeparateChart}	%
aging_kpi	{#F65658,#F49F36,#F5C860,#9AC17C,#4CB495,#569C9A,#60819C,#2F8AB1}	{TextUnitChart}	\N
aging_workforce_trend	{#24B0DD,#56B96D,#F8CF58,#F5AD4A,#E170A6,#ED6A45,#AF4137,#10294A}	{BarPercentChart,RadarChart,ColumnChart}	%
bike_network	{#a0b8e8,#b7ff98}	{DonutChart,BarChart}	公里
bike_map	{#a0b8e8,#b7ff98}	{MapLegend}	條
rent_quartiles	{#D3A021,#7C4DFF,#4EA3FF,#7CB342}	{QuartileChart}	元/月
rent_level	{#a0b8e8,#b7ff98}	{DistrictChart}	元
rental_subsidy_application_status	{#D3A021,#7C4DFF,#4EA3FF,#7CB342}	{TimelineSeparateChart}	件
purchase_subsidy_application_status	{#D3A021,#7C4DFF,#4EA3FF,#7CB342}	{TimelineSeparateChart}	件
repair_subsidy_application_status	{#D3A021,#7C4DFF,#4EA3FF,#7CB342}	{TimelineSeparateChart}	件
social_housing	{#D3A021,#7C4DFF,#4EA3FF,#7CB342}	{HeatmapChart}	間
\.


--
-- Data for Name: component_maps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.component_maps (id, index, title, type, source, size, icon, paint, property) FROM stdin;
70	youbike_realtime	youbike站點	symbol	geojson	\N	youbike	{}	[{"key":"sna","name":"場站名稱"},{"key":"sno","name":"場站ID"},{"key":"available_return_bikes","name":"可還車位"},{"key":"available_rent_general_bikes","name":"剩餘車輛"}]
99	youbike_realtime_metrotaipei	youbike站點	symbol	geojson	\N	youbike	{}	[{"key":"sna","name":"場站名稱"},{"key":"sno","name":"場站ID"},{"key":"available_return_bikes","name":"可還車位"},{"key":"available_rent_general_bikes","name":"剩餘車輛"}]
100	bike_network_tpe	自行車路網	line	geojson	\N	\N	{"line-color":["match",["get","direction"],"雙向","#097138","單向","#007BFF","#808080"]}	[\r\n  {"key": "data_time", "name": "數據時間"},\r\n  {"key": "route_name", "name": "路線名稱"},\r\n  {"key": "city_code", "name": "城市代碼"},\r\n  {"key": "city", "name": "城市"},\r\n  {"key": "road_section_start", "name": "起點路段"},\r\n  {"key": "road_section_end", "name": "終點路段"},\r\n  {"key": "direction", "name": "方向"},\r\n  {"key": "cycling_length", "name": "自行車道長度"},\r\n  {"key": "finished_time", "name": "完工時間"},\r\n  {"key": "update_time", "name": "更新時間"}\r\n]
101	bike_network_metrotaipei	自行車路網	line	geojson	\N	\N	{"line-color":["match",["get","direction"],"雙向","#097138","單向","#007BFF","#808080"]}	[\r\n  {"key": "data_time", "name": "數據時間"},\r\n  {"key": "route_name", "name": "路線名稱"},\r\n  {"key": "city_code", "name": "城市代碼"},\r\n  {"key": "city", "name": "城市"},\r\n  {"key": "road_section_start", "name": "起點路段"},\r\n  {"key": "road_section_end", "name": "終點路段"},\r\n  {"key": "direction", "name": "方向"},\r\n  {"key": "cycling_length", "name": "自行車道長度"},\r\n  {"key": "finished_time", "name": "完工時間"},\r\n  {"key": "update_time", "name": "更新時間"}\r\n]
1	rent_level	各行政區租金水準	fill	geojson	\N	\N	{\n  "fill-color": [\n    "case",\n    ["<", ["get", "rent_median"], 5000],\n    "#2f343a",\n\n    ["interpolate",\n      ["linear"],\n      ["get", "rent_median"],\n      5000, "#36404c",\n      8000, "#4b5b70",\n      11000, "#687b99",\n      14000, "#879dc3",\n      17000, "#a8bee8"\n    ]\n  ],\n  "fill-opacity": 0.88,\n  "fill-outline-color": "#26303a"\n}	[{"key":"PNAME","name":"縣市"},{"key":"TNAME","name":"行政區"},{"key":"rent_median","name":"租金50分位數"},{"key":"remark","name":"備註"}]
2	rent_level_metrotaipei	各行政區租金水準	fill	geojson	\N	\N	{\n  "fill-color": [\n    "case",\n    ["<", ["get", "rent_median"], 5000],\n    "#2f343a",\n\n    ["interpolate",\n      ["linear"],\n      ["get", "rent_median"],\n      5000, "#36404c",\n      8000, "#4b5b70",\n      11000, "#687b99",\n      14000, "#879dc3",\n      17000, "#a8bee8"\n    ]\n  ],\n  "fill-opacity": 0.88,\n  "fill-outline-color": "#26303a"\n}	[{"key":"PNAME","name":"縣市"},{"key":"TNAME","name":"行政區"},{"key":"rent_median","name":"租金50分位數"},{"key":"remark","name":"備註"}]
3	social_housing	社會住宅興辦進度	fill-extrusion	geojson	\N	\N	{\n  "fill-extrusion-color": "#3b82f6",\n  "fill-extrusion-height": [\n    "+",\n    200,\n    [\n      "*",\n      ["sqrt", ["to-number", ["get", "戶數"]]],\n      80\n    ]\n  ],\n  "fill-extrusion-base": 0,\n  "fill-extrusion-opacity": 0.85\n}	\N
\.


--
-- Data for Name: components; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.components (id, index, name) FROM stdin;
60	youbike_availability	YouBike使用情況
213	bike_network	自行車道路統計資料
212	ebus_percent	電動巴士比例
214	dependency_aging	扶養比及老化指數
216	city_age_distribution	全市年齡分區
218	aging_kpi	長照指標
215	aging_workforce_trend	高齡就業人口之年增結構
217	bike_map	自行車道路網圖資
44	rent_quartiles	租屋型態結構與租金
1	rent_level	各行政區租金水準
3	rental_subsidy_application_status	租金補貼受理情形
4	purchase_subsidy_application_status	自購住宅貸款利息補貼受理情形
5	repair_subsidy_application_status	修繕住宅貸款利息受理情形
6	social_housing	社會住宅興辦進度
\.


--
-- Data for Name: contributors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contributors (id, user_id, user_name, image, link, identity, description, include, created_at, updated_at) FROM stdin;
1	doit	臺北市政府資訊局	doit.png	https://doit.gov.taipei/	\N	\N	f	2024-05-09 01:58:47.164185+00	2024-05-09 01:58:47.164185+00
2	ntpc	新北市政府資訊中心	ntpc.png	https://www.imc.ntpc.gov.tw/	\N	\N	f	2024-05-09 01:58:47.164185+00	2024-05-09 01:58:47.164185+00
3	king	報報王	\N	https://github.com/tzuuuu/Taipei-City-Dashboard	\N	\N	f	2024-04-29 01:58:47.164185+00	2024-04-29 01:58:47.164185+00
\.


--
-- Data for Name: dashboard_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dashboard_groups (dashboard_id, group_id) FROM stdin;
106	2
356	2
355	3
359	3
358	3
360	4
400	3
400	4
362	5
\.


--
-- Data for Name: dashboards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dashboards (id, index, name, components, icon, updated_at, created_at) FROM stdin;
106	map-layers-taipei	圖資資訊	{217}	public	2025-03-12 01:59:00.512775+00	2024-03-21 10:04:24.928533+00
355	ltc_care_newtpe	長照關懷	{214,215,216,218}	elderly	2025-02-27 06:42:21.705931+00	2024-03-21 09:38:37.66+00
359	map-layers-metrotaipei	圖資資訊	{217}	public	2024-05-16 03:56:12.76016+00	2024-03-21 10:04:24.928533+00
358	practical_transportation_newtpe	務實交通	{60,212,213}	directions_car	2025-03-12 08:00:38.75842+00	2024-03-21 09:38:37.66+00
1	09a25cd9cb7d	收藏組件	\N	favorite	2025-03-14 07:34:22.247753+00	2025-03-14 07:34:22.247753+00
2	3245d9eace5f	我的新儀表板	{215,218,216,213,212,214,60,146}	star	2025-03-14 14:55:11.732116+00	2025-03-14 14:55:11.732116+00
360	07dd6b2a6bc0	收藏組件	\N	favorite	2026-04-28 03:12:29.258762+00	2026-04-28 03:12:29.258762+00
362	f5550dc8ed63	收藏組件	\N	favorite	2026-04-30 05:29:59.037538+00	2026-04-30 05:29:59.037538+00
356	ltc_care_tpe	長照關懷	{3,4,5,6,214,215,216,218}	elderly	2025-02-26 08:43:42.86017+00	2024-03-21 09:38:37.66+00
400	it_is_all_you_need	通勤達理	{1,3,4,5,6,44}	favorite	2026-04-29 05:25:52.001099+00	2026-04-29 05:25:52.001099+00
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, name, is_personal, create_by) FROM stdin;
1	public	f	\N
2	taipei	f	\N
3	metrotaipei	f	\N
4	user: 1's personal group	t	1
5	user: 6's personal group	t	6
\.


--
-- Data for Name: incidents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incidents (id, type, description, distance, latitude, longitude, place, "time", status) FROM stdin;
\.


--
-- Data for Name: issues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.issues (id, title, user_name, user_id, context, description, decision_desc, status, updated_by, created_at, updated_at) FROM stdin;
4	test	Drew	1	test	test	測試	不處理	doit	2024-03-15 07:33:39.695288+00	2024-07-26 06:37:55.038985+00
\.


--
-- Data for Name: query_charts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.query_charts (index, history_config, map_config_ids, map_filter, time_from, time_to, update_freq, update_freq_unit, source, short_desc, long_desc, use_case, links, contributors, created_at, updated_at, query_type, query_chart, query_history, city) FROM stdin;
aging_kpi	\N	{}	{}	static	\N	0	\N	主計處	此圖顯示雙北長照關懷各項指標。	此圖表呈現雙北長照關懷相關指標，包括 扶老比、扶幼比、扶養比 及 老化指數。扶老比代表每百名勞動人口需扶養的老年人口數，扶幼比則是需扶養的兒童人口數，而扶養比則合計這兩者，反映整體社會負擔程度。老化指數則比較老年人口與兒童人口比例，顯示人口結構的高齡化趨勢。這些數據可用於評估長照需求，並規劃資源分配與政策方向，以因應人口老化帶來的挑戰。	在制定長照政策時，政府可運用 扶老比、扶幼比、扶養比 及 老化指數 來評估未來照護需求。例如，某城市發現扶老比上升且老化指數超過 100，代表老年人口已多於兒童，預示長照需求將持續增加。政府可據此增設長照機構、強化居家照護服務，並鼓勵社區共融計畫，以減輕勞動人口的扶養壓力，確保高齡者獲得適切照顧。	{https://data.taipei/dataset/detail?id=64c8a3a0-3b9a-4f49-a13a-fb1eb2ffa4b1,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}	{doit,ntpc}	2023-12-20 05:56:00+00	2024-06-12 06:02:41.642+00	three_d	select y_axis,icon ,round(avg(data))data  \r\nfrom(\r\nselect '扶老比' as y_axis, percent30 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶幼比' as y_axis, percent31 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶養比' as y_axis, percent32 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '老化指數' as y_axis, percent33 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶老比' as y_axis, avg(percent30) as data ,'%' as icon \r\nfrom public.city_age_distribution_newtaipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型='計'\r\nunion all\r\nselect '扶幼比' as y_axis, avg(percent31) as data ,'%' as icon \r\nfrom public.city_age_distribution_newtaipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_newtaipei ) and 統計類型='計'\r\nunion all\r\nselect '扶養比' as y_axis, avg(percent32) as data ,'%' as icon \r\nfrom public.city_age_distribution_newtaipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型='計'\r\nunion all\r\nselect '老化指數' as y_axis, avg(percent33) as data ,'%' as icon \r\nfrom public.city_age_distribution_newtaipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型='計'\r\n)d\r\ngroup by y_axis,icon	\N	metrotaipei
aging_kpi	\N	{}	{}	static	\N	0	\N	主計處	此圖顯示臺北長照關懷各項指標。	此圖表呈現臺北長照關懷相關指標，包括 扶老比、扶幼比、扶養比 及 老化指數。扶老比代表每百名勞動人口需扶養的老年人口數，扶幼比則是需扶養的兒童人口數，而扶養比則合計這兩者，反映整體社會負擔程度。老化指數則比較老年人口與兒童人口比例，顯示人口結構的高齡化趨勢。這些數據可用於評估長照需求，並規劃資源分配與政策方向，以因應人口老化帶來的挑戰。	在制定長照政策時，政府可運用 扶老比、扶幼比、扶養比 及 老化指數 來評估未來照護需求。例如，某城市發現扶老比上升且老化指數超過 100，代表老年人口已多於兒童，預示長照需求將持續增加。政府可據此增設長照機構、強化居家照護服務，並鼓勵社區共融計畫，以減輕勞動人口的扶養壓力，確保高齡者獲得適切照顧。	{https://data.taipei/dataset/detail?id=64c8a3a0-3b9a-4f49-a13a-fb1eb2ffa4b1}	{doit}	2023-12-20 05:56:00+00	2024-06-12 06:02:41.642+00	three_d	select y_axis,icon ,round(avg(data))data  \r\nfrom(\r\nselect '扶老比' as y_axis, percent30 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶幼比' as y_axis, percent31 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '扶養比' as y_axis, percent32 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\nunion all\r\nselect '老化指數' as y_axis, percent33 as data ,'%' as icon \r\nfrom public.city_age_distribution_taipei \r\nwhere 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別='總計' and 統計類型='計'\r\n)d\r\ngroup by y_axis,icon	\N	taipei
aging_workforce_trend	\N	\N	\N	static	\N	\N	\N	主計處	顯示雙北就業人口之年齡結構時間數列統計資料	雙北地區人口年齡分配按月別時間數列統計資料，記錄臺北市與新北市各年齡層人口數的月度變化，涵蓋從0歲至65歲以上等多個年齡區間。該資料反映雙北地區人口在不同年齡層之分布情形，具備連續性與時間性，可作為分析區域人口結構、行政規劃及社會資源配置的重要參考。透過長期追蹤，亦能協助了解人口構成在不同時間點的變化狀況與組成比例，有助於支持各項人口相關研究與實務應用。	適用於跨域分析或探討都市群體共通趨勢，涵蓋臺北市與新北市兩地，常見於區域整體發展、通勤流動、就業市場整合、住宅與交通規劃等議題。亦可用於比較兩市人口結構差異、公共資源分布或整合性施政評估。例如：雙北地區勞動參與率變化、雙北通勤族群結構分析、雙北教育資源均衡程度探討等。	{https://data.taipei/dataset/detail?id=df320c78-f66b-4504-92b4-cf2a2eb46f1b,https://data.ntpc.gov.tw/datasets/c285509a-7fb2-434f-8542-0b4986c337a8}	{doit,ntpc}	2024-11-28 05:56:00+00	2024-12-10 02:59:39.341+00	three_d	select x_axis,y_axis,round(avg(percentage)) as data\r\nfrom (select year as x_axis,'1.非高齡就業人口' as y_axis,sum(percentage) as percentage  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure not in ('就業人口','就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲','就業人口按年齡別/65歲以上')\r\ngroup by year \r\nunion all \r\nselect year as x_axis,'2.中高齡就業人口' as y_axis,percentage as data  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲')\r\nunion all \r\nselect year as x_axis,'3.高齡就業人口' as y_axis,percentage as data  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/65歲以上')\r\nunion all \r\nselect year as x_axis,'1.非高齡就業人口' as y_axis,sum(percentage) as data  from employment_age_structure_new_tpe\r\nwhere  gender ='總計' and age_structure not in ('就業人口','就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲','就業人口按年齡別/65歲以上')\r\ngroup by year \r\nunion all \r\nselect year as x_axis,'2.中高齡就業人口' as y_axis,percentage as data  from employment_age_structure_new_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲')\r\nunion all \r\nselect year as x_axis,'3.高齡就業人口' as y_axis,percentage as data  from employment_age_structure_new_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/65歲以上'))d\r\nwhere x_axis >'2016'\r\ngroup by x_axis,y_axis \r\norder by 1,2	\N	metrotaipei
aging_workforce_trend	\N	\N	\N	static	\N	\N	\N	主計處	顯示臺北就業人口之年齡結構時間數列統計資料	臺北市人口年齡分配按月別時間數列統計資料，提供各年齡層人口數的定期統計結果，依月別呈現，涵蓋從幼年、青壯年至高齡等不同年齡區間。此資料可作為觀察人口結構組成的重要依據，反映各年齡層在人口總數中的分布情形。透過持續的月別紀錄，可供相關單位進行人口結構分析、資源分配規劃及政策評估等多元應用。資料內容具體、連續，適合用於進行長期與跨時比較之研究分析。	適用於聚焦單一行政區之人口、就業、教育、社會福利、都市規劃等議題。多用於市政層級的政策分析、市內人口結構觀察、社會服務配置研究，以及針對臺北市特定區域（如中正區、大安區等）的細部分析。例如：臺北市高齡人口比例變化、臺北市各區幼兒園分布狀況等。	{https://data.taipei/dataset/detail?id=df320c78-f66b-4504-92b4-cf2a2eb46f1b}	{doit}	2024-11-28 05:56:00+00	2025-03-19 10:25:55.340887+00	three_d	select x_axis,y_axis,round(avg(percentage)) as data\r\nfrom (select year as x_axis,'1.非高齡就業人口' as y_axis,sum(percentage) as percentage  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure not in ('就業人口','就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲','就業人口按年齡別/65歲以上')\r\ngroup by year \r\nunion all \r\nselect year as x_axis,'2.中高齡就業人口' as y_axis,percentage as data  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/45-49歲','就業人口按年齡別/50-54歲','就業人口按年齡別/55-59歲','就業人口按年齡別/60-64歲')\r\nunion all \r\nselect year as x_axis,'3.高齡就業人口' as y_axis,percentage as data  from employment_age_structure_tpe\r\nwhere  gender ='總計' and age_structure  in ('就業人口按年齡別/65歲以上')\r\n)d\r\nwhere x_axis >'2016'\r\ngroup by x_axis,y_axis \r\norder by 1,2	\N	taipei
bike_map	\N	{100,101}	{}	static	\N	\N	\N	交通局交工處	顯示雙北當前自行車路網分布。	顯示雙北當前自行車路網分布。雙北擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，雙北政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。	使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。	{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/NewTaipei?%24top=30&%24format=JSON}	{doit,ntpc}	2023-12-20 05:56:00+00	2024-01-11 06:26:02.069+00	map_legend	SELECT unnest(array['自行車路網']) as name, 'line' as type	\N	metrotaipei
bike_map	\N	{100}	{}	static	\N	\N	\N	交通局交工處	顯示臺北當前自行車路網分布。	顯示臺北市當前自行車路網分布。臺北市擁有完善的自行車路網，主要由河濱自行車道與市區自行車道組成。河濱自行車道沿淡水河、基隆河、新店溪與景美溪等河岸規劃，提供連續、寬敞且景觀良好的騎行空間，深受市民與遊客喜愛。市區自行車道則分布於市內多條主要幹道，包括敦化南北路、承德路、松隆路、松德路、和平西路、民生東路、八德路、光復南路、永吉路等，串聯重要商圈、學區與轉運點，提升日常通勤與短程移動的便利性。臺北市政府持續推動「自行車道願景計畫」，整合市區與河濱車道系統、銜接捷運與轉乘據點，並優化既有路線與設施，致力打造友善、安全的騎乘環境。	使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。	{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON}	{doit}	2023-12-20 05:56:00+00	2024-01-11 06:26:02.069+00	map_legend	SELECT unnest(array['自行車路網']) as name, 'line' as type	\N	taipei
bike_network	\N	{100}	{"mode":"byParam","byParam":{"xParam":"direction"}}	static	\N	\N	\N	交通局交工處	顯示臺北市當前自行車路網分布。	顯示臺北市當前自行車路網分布。臺北市擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，臺北市政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。	使用於地圖分析、交通規劃與旅遊建議，臺北市的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。	{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON}	{doit}	2023-12-20 05:56:00+00	2024-01-11 06:26:02.069+00	two_d	select  direction as x_axis ,round(sum(cycling_length)/1000) as data\r\nfrom public.bike_network_tpe  \r\nwhere direction !=''\r\ngroup by direction	\N	taipei
city_age_distribution	\N	\N	\N	static	\N	\N	\N	主計處	顯示雙北年齡分區	顯示雙北地區年齡分區，將人口依年齡群體劃分至不同城市區域。此分區有助於了解臺北市與新北市在人口結構上的差異與分布情形，包括各行政區的老化程度、青壯年與幼年人口比例，為政策制定者、城市規劃者及研究人員提供精確的分析依據。透過此資料，可進行跨區域的公共資源配置、社區規劃與長期照護服務設計，確保雙北地區在教育、交通、醫療與社福等層面能因應不同年齡層需求，促進整體都市發展的均衡與永續。	使用於城市規劃、社會政策制定及人口統計分析，雙北地區年齡分區數據可協助政府與研究機構掌握人口結構的變化情形。此指標適用於評估各年齡層在臺北市與新北市的區域分布，有助於規劃教育資源配置、醫療設施布建及長照服務佈點。除此之外，企業亦可依據此數據進行市場分析，針對不同年齡族群設計產品與服務，強化區域經營策略的精準度與效益。此資料為雙北區域在政策與產業發展上的重要基礎依據。	{https://data.taipei/dataset/detail?id=1e0c58e9-6aa5-4acb-a5a1-f60bacad60f3,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}	{doit,ntpc}	2024-11-28 05:56:00+00	2025-03-20 01:33:28.634747+00	three_d	select x_axis,y_axis,round(sum(data)/1000) data\r\nfrom(select 區域別 as x_axis,'0_14歲人口數' as y_axis,percent24 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'15_64歲人口數' as y_axis,percent26 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'65歲以上人口數' as y_axis,percent28 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'0_14歲人口數' as y_axis,percent24 as data\r\nfrom \r\npublic.city_age_distribution_newtaipei \r\nwhere 區域別 not in ('總計','新北市') and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_newtaipei)\r\nunion all\r\nselect 區域別 as x_axis,'15_64歲人口數' as y_axis,percent26 as data\r\nfrom \r\npublic.city_age_distribution_newtaipei \r\nwhere 區域別 not in ('總計','新北市') and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_newtaipei)  \r\nunion all\r\nselect 區域別 as x_axis,'65歲以上人口數' as y_axis,percent28 as data\r\nfrom \r\npublic.city_age_distribution_newtaipei \r\nwhere 區域別 not in ('總計','新北市') and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_newtaipei)\r\n)d\r\ngroup by x_axis,y_axis\r\n	\N	metrotaipei
city_age_distribution	\N	\N	\N	static	\N	\N	\N	主計處	顯示臺北市年齡分區	顯示臺北市年齡分區，將市民人口依年齡群體劃分至不同行政區域。此分區有助於掌握各區人口結構分布，包括幼年人口、青壯年人口與高齡人口比例，為政策制定者、城市規劃單位及研究人員提供重要的分析依據。透過此資料，可進行公共資源配置、社區照護設計及設施規劃，確保臺北市在教育、醫療、交通與長照等方面的發展，能更貼近各年齡層居民的實際需求，促進人口結構與城市功能的平衡發展。	使用於城市規劃、社會政策制定及人口統計分析，臺北市年齡分區數據可協助市府機關與研究單位掌握市內人口結構的變化。此指標適用於評估各年齡層在不同行政區的分布情形，有助於規劃教育資源、醫療設施及長照服務的佈局與優化。此外，企業亦可依據此資料進行在地市場分析，針對不同年齡族群設計產品與服務，提升區域經營策略的精準度與實效性，強化對臺北市多元人口需求的回應。\n\n\n\n\n\n\n\n\n	{https://data.taipei/dataset/detail?id=1e0c58e9-6aa5-4acb-a5a1-f60bacad60f3}	{doit}	2024-11-28 05:56:00+00	2025-02-21 07:52:55.450103+00	three_d	select x_axis,y_axis,round(sum(data)/1000) data\r\nfrom(select 區域別 as x_axis,'0_14歲人口數' as y_axis,percent24 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'15_64歲人口數' as y_axis,percent26 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\nunion all\r\nselect 區域別 as x_axis,'65歲以上人口數' as y_axis,percent28 as data\r\nfrom \r\npublic.city_age_distribution_taipei \r\nwhere 區域別 != '總計' and 年份=(select max(年份)\r\nfrom \r\npublic.city_age_distribution_taipei)\r\n)d\r\ngroup by x_axis,y_axis\r\n	\N	taipei
dependency_aging	\N	\N	\N	static	\N	\N	\N	主計處	顯示雙北扶養比及老化指數時間數列統計資料	顯示雙北扶養比及老化指數時間數列統計資料。雙北政府主計處提供了扶養比和老化指數資料，詳細記錄了各年齡段人口比例的變化情況。這些資料有助於分析雙北人口結構的演變，評估青壯年人口對幼年和老年人口的扶養負擔，以及社會老化程度。透過這些統計資料，政策制定者和研究人員可以深入了解人口趨勢，為未來的社會福利和經濟發展規劃提供參考。	使用於人口結構分析、社會福利規劃與經濟發展評估，雙北的扶養比與老化指數數據提供決策參考。政府機構可透過這些統計資料評估勞動力供給與社會扶養負擔，進而調整退休政策與醫療資源配置。企業可運用數據研判市場趨勢，規劃銀髮族產品與服務。學術研究則可透過時間序列分析，探討人口老化對經濟與社會的影響，為未來城市發展與人口政策提供科學依據。\r\n	{https://data.taipei/dataset/detail?id=aafb15dc-5508-4091-bd48-a708e60f6698,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}	{doit,ntpc}	2024-11-28 05:56:00+00	2024-12-10 02:59:39.341+00	time	select \r\nx_axis,y_axis,round(avg(data)) data\r\nfrom (\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'扶養比' as y_axis,total_dependency_ratio as data  \r\nfrom \r\ndependency_ratio_and_aging_index_tpe\r\nunion all\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'老化指數' as y_axis ,aging_index \r\nfrom \r\ndependency_ratio_and_aging_index_tpe\r\nunion all\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'扶養比' as y_axis,total_dependency_ratio  \r\nfrom \r\ndependency_ratio_and_aging_index_new_tpe\r\nunion all\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'老化指數' as y_axis ,aging_index \r\nfrom \r\ndependency_ratio_and_aging_index_new_tpe\r\n)d\r\nwhere x_axis >'2013-01-01 00:00:00.000'\r\ngroup by x_axis,y_axis\r\norder by 1\r\n	\N	metrotaipei
dependency_aging	\N	\N	\N	static	\N	\N	\N	主計處	顯示臺北市扶養比及老化指數時間數列統計資料	顯示臺北市扶養比及老化指數時間數列統計資料。臺北市政府主計處提供了扶養比和老化指數資料，詳細記錄了各年齡段人口比例的變化情況。這些資料有助於分析臺北市人口結構的演變，評估青壯年人口對幼年和老年人口的扶養負擔，以及社會老化程度。透過這些統計資料，政策制定者和研究人員可以深入了解人口趨勢，為未來的社會福利和經濟發展規劃提供參考。	使用於人口結構分析、社會福利規劃與經濟發展評估，臺北市的扶養比與老化指數數據提供決策參考。政府機構可透過這些統計資料評估勞動力供給與社會扶養負擔，進而調整退休政策與醫療資源配置。企業可運用數據研判市場趨勢，規劃銀髮族產品與服務。學術研究則可透過時間序列分析，探討人口老化對經濟與社會的影響，為未來城市發展與人口政策提供科學依據。\r\n	{https://data.taipei/dataset/detail?id=aafb15dc-5508-4091-bd48-a708e60f6698}	{doit}	2024-11-28 05:56:00+00	2025-02-25 01:43:21.031142+00	time	select \r\nx_axis,y_axis,round(avg(data)) data\r\nfrom (\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'扶養比' as y_axis,total_dependency_ratio as data  \r\nfrom \r\ndependency_ratio_and_aging_index_tpe\r\nunion all\r\nselect TO_TIMESTAMP(end_of_year , 'YYYY-MM-DD HH24:MI:SS.MS') AT TIME ZONE 'Asia/Taipei' AS x_axis,\r\n'老化指數' as y_axis ,aging_index \r\nfrom \r\ndependency_ratio_and_aging_index_tpe\r\n)d\r\nwhere x_axis >'2013-01-01 00:00:00.000'\r\ngroup by x_axis,y_axis\r\norder by 1\r\n	\N	taipei
ebus_percent	\N	\N	\N	static	\N	\N	\N	交通局	顯示雙北電動公車比例	此圖顯示雙北地區電動公車的比例，呈現臺北市與新北市公車車隊中電動車所占比重，以及近年來電動公車數量的成長情形。圖表比較傳統燃油公車與電動公車的比例變化，並標示雙北兩市政府推動電動化政策、補助措施及其帶來的環保效益。透過這些數據，可評估雙北地區電動公車的普及程度，及其對減碳、空氣品質改善的實質貢獻，進一步作為規劃大臺北地區公共運輸電動化策略的重要依據，推動都會區交通體系朝向低碳永續發展。	可用於評估雙北地區公共運輸電動化進程，透過此圖顯示臺北市與新北市公車系統中電動公車的占比及成長趨勢。圖表比較傳統燃油公車與電動公車的比例變化，並標示雙北兩市推動相關政策、補助措施及其所帶來的環保效益。透過這些數據，可評估雙北地區電動公車的普及率，以及其在減碳排放與空氣品質改善上的具體貢獻，進而作為制定更完善的都會區公共運輸電動化策略的重要依據，推動雙北朝向低碳永續城市目標發展。	{https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/NewTaipei?%24top=30&%24format=JSON}	{doit,ntpc}	2025-02-15 05:56:00+00	2024-02-15 02:59:39.341+00	percent	select '電動公車數量' as x_axis,y_axis,sum(data) data from \r\n(select '電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_new_tpe\r\nwhere plate_numb like 'E%'\r\nunion all\r\nselect '非電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_new_tpe\r\nwhere plate_numb not like 'E%'\r\nunion all\r\nselect '電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_tpe\r\nwhere plate_numb like 'E%'\r\nunion all\r\nselect '非電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_tpe)d\r\ngroup by \r\ny_axis\r\n	\N	metrotaipei
ebus_percent	\N	\N	\N	static	\N	\N	\N	交通局	顯示臺北電動公車比例	此圖顯示臺北市電動公車的比例，呈現全市公車車隊中電動車所占比重，以及近年來電動公車數量的成長情形。圖表比較傳統燃油公車與電動公車的比例變化，並標示臺北市政府推動電動化政策、補助措施及其帶來的環保效益。透過這些數據，可評估臺北市電動公車的普及程度，及其在減碳與空氣品質改善上的貢獻，有助於進一步規劃更完善的公共運輸電動化策略，推動城市交通朝向低碳永續目標邁進。	可用於評估臺北市公共運輸電動化的進程，透過此圖顯示電動公車在市區公車總數中的占比及其成長趨勢。圖表呈現傳統燃油公車與電動公車的比例變化，並標示臺北市政府推動的政策措施、補助方案及相關環保效益等影響因素。透過這些數據，可分析臺北市電動公車的普及程度及其在減碳排放與空氣品質改善方面的貢獻，有助於進一步規劃更完善的公共運輸電動化策略，推動臺北朝向低碳與永續發展的城市目標邁進。	{https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/Taipei?%24top=30&%24format=JSON}	{doit}	2025-02-15 05:56:00+00	2025-02-20 09:11:21.620625+00	percent	select '電動公車數量' as x_axis,y_axis,sum(data) data from \r\n(\r\nselect '電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_tpe\r\nwhere plate_numb like 'E%'\r\nunion all\r\nselect '非電動巴士' as y_axis,count(*) as  data\r\nfrom public.bus_info_tpe)d\r\ngroup by \r\ny_axis	\N	taipei
youbike_availability	\N	{99}	\N	current	\N	10	minute	交通局	顯示當前雙北共享單車YouBike的使用情況。	顯示雙北地區（臺北市與新北市）當前共享單車 YouBike 的使用情況，格式為可借車輛數／全區車位數。資料來源為兩市交通局公開資料，每5分鐘更新一次，提供即時的車輛可用資訊與站點使用狀況，有助於掌握整體運行效率與民眾使用情形，亦可作為交通管理與營運調度的參考依據。	藉由顯示雙北地區 YouBike 的使用情況，以及觀察可借車輛數約為車柱總數的一半，可大致掌握目前停放於站點與使用中車輛的整體分布情形。使用者亦可透過地圖模式查詢雙北各站點的即時資訊，包括可借車輛數、可還空位數及站點位置，方便規劃路線與掌握使用狀況，提升共享單車的便利性與使用效率。	{https://tdx.transportdata.tw/api-service/swagger/basic/2cc9b888-a592-496f-99de-9ab35b7fb70d#/Bike/BikeApi_Availability_2181,https://tdx.transportdata.tw/api/basic/v2/Bike/Availability/City/NewTaipei?%24top=30&%24format=JSON}	{doit,ntpc}	2023-12-20 05:56:00+00	2024-03-19 06:08:17.99+00	percent	select x_axis,y_axis,sum(data)data\r\nfrom (select '在站車輛' as x_axis, \r\nunnest(ARRAY['可借車輛', '空位']) as y_axis, \r\nunnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data\r\nfrom tran_ubike_realtime_new_tpe\r\nunion all \r\nselect '在站車輛' as x_axis, \r\nunnest(ARRAY['可借車輛', '空位']) as y_axis, \r\nunnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data\r\nfrom tran_ubike_realtime)d\r\ngroup by x_axis,y_axis	\N	metrotaipei
youbike_availability	\N	{70}	\N	current	\N	10	minute	交通局	顯示當前臺北市共享單車YouBike的使用情況。	顯示臺北市當前共享單車 YouBike 的使用情況，格式為可借車輛數／全市車位數。資料來源為臺北市政府交通局公開資料，每5分鐘更新一次，反映即時的使用狀況與車輛調度情形，可作為交通監測與市民使用參考依據。	藉由臺北市 YouBike 使用情況的顯示，以及全市可借車輛數約為車柱總數的一半，可大致掌握目前停放於站點與正在使用中的車輛數量。使用者可透過地圖模式查詢臺北市各站點的即時資訊，包括可借車輛數、可還空位數及站點位置，方便即時掌握使用狀況，提升共享單車的使用效率與便利性。	{https://tdx.transportdata.tw/api-service/swagger/basic/2cc9b888-a592-496f-99de-9ab35b7fb70d#/Bike/BikeApi_Availability_2181}	{doit}	2023-12-20 05:56:00+00	2024-03-19 06:08:17.99+00	percent	select '在站車輛' as x_axis, \r\nunnest(ARRAY['可借車輛', '空位']) as y_axis, \r\nunnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data\r\nfrom tran_ubike_realtime	\N	taipei
rent_quartiles	\N	{}	{}	static	\N	0	\N	內政部租賃資料	顯示租金四分位，支援縣市/行政區篩選。	顯示各租屋類型租金四分位（Q1/中位數/Q3）與箱體區間，提供縣市/行政區下拉篩選（含全市彙整）。有效租約樣本少於40筆的行政區會顯示無資料說明。	比較不同行政區各類型租金的Q1/中位數/Q3差異，理解價格分布偏態，支援房市監測與社會住宅規劃。	{}	{doit}	2026-04-29 02:44:30.206957+00	2026-04-29 08:58:38.77403+00	quartile	\n    WITH base AS (\n      SELECT\n        city_name,\n        district_name,\n        house_category,\n        case_count,\n        q1_rent,\n        median_rent,\n        q3_rent\n      FROM public.rent_quartiles_stats\n    ),\n    district_totals AS (\n      SELECT\n        city_name,\n        district_name,\n        SUM(case_count) AS district_case_count\n      FROM base\n      GROUP BY city_name, district_name\n    )\n    SELECT\n      CASE WHEN b.house_category = '不分類' THEN '全部' ELSE b.house_category END AS name,\n      CASE\n        WHEN b.house_category = '不分類' THEN 'pie_chart'\n        WHEN b.house_category = '整戶(層)' THEN 'apartment'\n        WHEN b.house_category = '獨立套房' THEN 'bed'\n        WHEN b.house_category = '分租套(雅)房' THEN 'group'\n        ELSE 'stacked_line_chart'\n      END AS icon,\n\n      b.city_name,\n      b.district_name,\n\n      -- no-data 時把四分位設 NULL，前端才會顯示提示\n      CASE\n        WHEN dt.district_case_count < 40 AND b.district_name <> '全市' THEN NULL\n        ELSE b.q1_rent\n      END AS min,\n      CASE\n        WHEN dt.district_case_count < 40 AND b.district_name <> '全市' THEN NULL\n        ELSE b.q1_rent\n      END AS q1,\n      CASE\n        WHEN dt.district_case_count < 40 AND b.district_name <> '全市' THEN NULL\n        ELSE b.median_rent\n      END AS median,\n      CASE\n        WHEN dt.district_case_count < 40 AND b.district_name <> '全市' THEN NULL\n        ELSE b.q3_rent\n      END AS q3,\n      CASE\n        WHEN dt.district_case_count < 40 AND b.district_name <> '全市' THEN NULL\n        ELSE b.q3_rent\n      END AS max,\n\n      (dt.district_case_count < 40 AND b.district_name <> '全市') AS is_no_data,\n      CASE\n        WHEN dt.district_case_count < 40 AND b.district_name <> '全市'\n          THEN '有效租約樣本 未達40筆 因此無此行政區資料'\n        ELSE NULL\n      END AS no_data_reason,\n\n      CASE b.house_category\n        WHEN '不分類' THEN 1\n        WHEN '整戶(層)' THEN 2\n        WHEN '獨立套房' THEN 3\n        WHEN '分租套(雅)房' THEN 4\n        ELSE 99\n      END AS sort_key\n    FROM base b\n    JOIN district_totals dt\n      ON dt.city_name = b.city_name\n     AND dt.district_name = b.district_name\n    ORDER BY\n      b.city_name,\n      CASE WHEN b.district_name = '全市' THEN 0 ELSE 1 END,\n      b.district_name,\n      sort_key\n  	\N	metrotaipei
rental_subsidy_application_status	\N	\N	\N	static	\N	\N	\N	都發局	呈現台北租金補貼申請與核定戶數的歷年變化趨勢	本組件展示臺北市歷年租金補貼之「申請戶數」與「核定戶數」變化情形，透過多條折線呈現不同城市與指標的長期趨勢，協助使用者觀察租屋補貼需求與實際核定規模的變動關係。圖中可比較兩市在不同年度的申請熱度、政策核定量能，以及申請與核定之間的落差情形，進一步反映租屋市場壓力與補貼資源配置狀況。資料來源為政府公開之租金補貼統計資料，依年度彙整申請與核定戶數，並持續更新以反映最新政策執行成果。\n自111年度起，租金補貼改由中央推動「三百億元擴大租金補貼專案」，取代原地方政府辦理機制。以臺北市為例，111年申請戶數為42,546戶、核准戶數為35,274戶，並另提供加碼補貼（核准3,983戶），顯示政策擴大後補貼量能與申請需求皆明顯提升。（資料更新至113年3月22日）	可用於評估租金補貼政策成效與市場需求變化，例如觀察申請戶數快速上升是否代表租屋壓力增加，或核定戶數成長是否反映政策擴張。民眾可藉此了解補貼申請趨勢與競爭程度，作為是否申請補助的參考；政府與研究單位則可透過比較雙北差異與歷年變化，分析補貼資源是否充足、政策是否有效回應需求，並作為未來住宅政策與社會福利調整之依據。	{https://data.taipei/dataset/detail?id=6297943a-1e71-480d-967c-635855df66fe}	{king}	2026-04-30 05:56:00+00	2026-04-30 05:56:00+00	time	select\n  to_date("項目"::text || '-01-01', 'YYYY-MM-DD') as x_axis,\n  y_axis,\n  data\nfrom (\n  select\n    "項目",\n    '臺北市申請戶數' as y_axis,\n    "租金補貼申請戶數" as data\n  from rental_subsidy_application_status_tp\n  where "縣市" = '臺北市'\n\n  union all\n\n  select\n    "項目",\n    '臺北市核定戶數' as y_axis,\n    "租金補貼核定戶數" as data\n  from rental_subsidy_application_status_tp\n  where "縣市" = '臺北市'\n) d\norder by x_axis, y_axis;	\N	taipei
rental_subsidy_application_status	\N	\N	\N	static	\N	\N	\N	都發局	呈現雙北租金補貼申請與核定戶數的歷年變化趨勢	本組件展示臺北市與新北市歷年租金補貼之「申請戶數」與「核定戶數」變化情形，透過多條折線呈現不同城市與指標的長期趨勢，協助使用者觀察租屋補貼需求與實際核定規模的變動關係。圖中可比較兩市在不同年度的申請熱度、政策核定量能，以及申請與核定之間的落差情形，進一步反映租屋市場壓力與補貼資源配置狀況。資料來源為政府公開之租金補貼統計資料，依年度彙整申請與核定戶數，並持續更新以反映最新政策執行成果。\n\n自111年度起，租金補貼改由中央推動「三百億元擴大租金補貼專案」，取代原地方政府辦理機制。以臺北市為例，111年申請戶數為42,546戶、核准戶數為35,274戶，並另提供加碼補貼（核准3,983戶），顯示政策擴大後補貼量能與申請需求皆明顯提升。（資料更新至113年3月22日）	可用於評估租金補貼政策成效與市場需求變化，例如觀察申請戶數快速上升是否代表租屋壓力增加，或核定戶數成長是否反映政策擴張。民眾可藉此了解補貼申請趨勢與競爭程度，作為是否申請補助的參考；政府與研究單位則可透過比較雙北差異與歷年變化，分析補貼資源是否充足、政策是否有效回應需求，並作為未來住宅政策與社會福利調整之依據。	{https://data.taipei/dataset/detail?id=6297943a-1e71-480d-967c-635855df66fe,https://data.ntpc.gov.tw/datasets/502d1589-3693-4f2c-9c05-22e3ec37330d}	{king}	2026-04-30 05:56:00+00	2026-04-30 05:56:00+00	time	select\n  to_date("項目"::text || '-01-01', 'YYYY-MM-DD') as x_axis,\n  y_axis,\n  data\nfrom (\n  select\n    "項目",\n    '臺北市申請戶數' as y_axis,\n    "租金補貼申請戶數" as data\n  from rental_subsidy_application_status_ntp\n  where "縣市" = '臺北市'\n\n  union all\n\n  select\n    "項目",\n    '臺北市核定戶數' as y_axis,\n    "租金補貼核定戶數" as data\n  from rental_subsidy_application_status_ntp\n  where "縣市" = '臺北市'\n  \n  union all\n\n  select\n    "項目",\n    '新北市申請戶數' as y_axis,\n    "租金補貼申請戶數" as data\n  from rental_subsidy_application_status_ntp\n  where "縣市" = '新北市'\n  \n  union all\n\n  select\n    "項目",\n    '新北市核定戶數' as y_axis,\n    "租金補貼核定戶數" as data\n  from rental_subsidy_application_status_ntp\n  where "縣市" = '新北市'\n) d\norder by x_axis, y_axis;	\N	metrotaipei
rent_level	\N	{2}	{\n  "mode": "byParam",\n  "byParam": {\n    "xParam": "TNAME",\n    "multi": true\n  }\n}	static	\N	\N	\N	內政部國土管理署	顯示雙北各行政區之租金水準	顯示雙北各行政區之租金水準，採用租金中位數呈現不同區域的租屋成本差異，協助使用者快速掌握各區租金分布情形，並以此評估生活居住成本。資料來源為內政部國土管理署「300 億元中央擴大租金補貼專案計畫」，統計範圍為截至 114 年 9 月 30 日之有效租賃契約，約 71.7 萬筆資料，並僅納入樣本數達 40 筆以上之行政區進行分析。	用於租屋與通勤決策分析，透過比較各行政區租金水準，搭配通勤時間或交通可達性，協助民眾在「時間成本」與「居住成本」之間取得平衡，選擇最適合的居住區域。另可進行城市治理與住宅政策分析，透過觀察各行政區租金分布差異，評估區域居住壓力與租屋市場結構，作為租金補貼政策、社會住宅規劃及都市發展決策之參考依據	{https://pip.moi.gov.tw/Publicize/Info/E1080}	{king}	2026-04-29 09:19:30.92388+00	2026-04-29 09:19:30.92388+00	two_d	SELECT \n  "行政區" AS x_axis,\n  "租金50分位數" AS data,\n  TO_CHAR("租金50分位數", 'FM999,999,999') AS label\nFROM public.rent_level	\N	metrotaipei
purchase_subsidy_application_status	\N	\N	\N	static	\N	\N	\N	都發局	呈現雙北自購住宅貸款利息補貼申請與核定戶數的歷年變化趨勢	展示臺北市與新北市自購住宅貸款利息補貼之「申請戶數」與「核定戶數」歷年變化情形，透過折線圖呈現不同城市與指標的趨勢走向。使用者可比較兩市在各年度的申請需求與實際核定情形，觀察補貼資源配置與核定量能之變化，並進一步分析申請與核定之間的差距，了解住宅金融補助政策對購屋族群的支持程度。\n\n需注意，臺北市相關資料僅統計至2022年，後續年度暫無資料，進行跨年度或跨城市比較時應留意資料完整性差異。	用於評估住宅補貼政策對購屋族群的支持效果，例如觀察申請戶數上升是否代表購屋壓力增加，或核定戶數變化是否反映政策調整方向。民眾可透過此趨勢了解補貼申請競爭程度與歷年變化，作為購屋與申請補助的參考；政府與研究單位則可透過雙北比較與長期趨勢分析，檢視補貼政策是否有效回應市場需求，並作為住宅政策與金融支持措施優化之依據。	{https://data.taipei/dataset/detail?id=6297943a-1e71-480d-967c-635855df66fe,https://data.ntpc.gov.tw/datasets/502d1589-3693-4f2c-9c05-22e3ec37330d}	{king}	2026-04-30 05:56:00+00	2026-04-30 05:56:00+00	time	select\n  to_date("項目"::text || '-01-01', 'YYYY-MM-DD') as x_axis,\n  y_axis,\n  data\nfrom (\n  select\n    "項目",\n    '臺北市申請戶數' as y_axis,\n    "購買申請戶數" as data\n  from purchase_subsidy_application_status_ntp\n  where "縣市" = '臺北市'\n\n  union all\n\n  select\n    "項目",\n    '臺北市核定戶數' as y_axis,\n    "購買核定戶數" as data\n  from purchase_subsidy_application_status_ntp\n  where "縣市" = '臺北市'\n  \n  union all\n\n  select\n    "項目",\n    '新北市申請戶數' as y_axis,\n    "購買申請戶數" as data\n  from purchase_subsidy_application_status_ntp\n  where "縣市" = '新北市'\n  \n  union all\n\n  select\n    "項目",\n    '新北市核定戶數' as y_axis,\n    "購買核定戶數" as data\n  from purchase_subsidy_application_status_ntp\n  where "縣市" = '新北市'\n) d\norder by x_axis, y_axis;	\N	metrotaipei
repair_subsidy_application_status	\N	\N	\N	static	\N	\N	\N	都發局	呈現雙北修繕住宅貸款利息補貼申請與核定戶數的歷年變化趨勢	展示臺北市與新北市修繕住宅貸款利息補貼之「申請戶數」與「核定戶數」歷年變化情形，透過折線圖呈現不同城市與指標的趨勢走向。使用者可比較兩市在各年度的申請需求與實際核定情形，觀察補貼資源配置與核定量能之變化，並進一步分析申請與核定之間的差距，了解住宅修繕補助政策對既有住宅改善的支持程度。\n\n需注意，臺北市相關資料僅統計至2022年，後續年度暫無資料，進行跨年度或跨城市比較時應留意資料完整性差異。	可用於評估住宅修繕補貼政策之推動成效，例如觀察申請戶數變化是否反映老屋修繕需求增減，或核定戶數趨勢是否代表政府資源投入程度。民眾可透過此趨勢了解補貼申請情形，作為是否進行住宅修繕與申請補助的參考；政府與研究單位則可透過雙北比較與長期趨勢分析，檢視補助政策是否有效回應住宅老化問題，並作為未來住宅改善與居住品質提升政策之依據。	{https://data.taipei/dataset/detail?id=6297943a-1e71-480d-967c-635855df66fe,https://data.ntpc.gov.tw/datasets/502d1589-3693-4f2c-9c05-22e3ec37330d}	{king}	2026-04-30 05:56:00+00	2026-04-30 05:56:00+00	time	select\n  to_date("項目"::text || '-01-01', 'YYYY-MM-DD') as x_axis,\n  y_axis,\n  data\nfrom (\n  select\n    "項目",\n    '臺北市申請戶數' as y_axis,\n    "修繕申請戶數" as data\n  from repair_subsidy_application_status_ntp\n  where "縣市" = '臺北市'\n\n  union all\n\n  select\n    "項目",\n    '臺北市核定戶數' as y_axis,\n    "修繕核定戶數" as data\n  from repair_subsidy_application_status_ntp\n  where "縣市" = '臺北市'\n  \n  union all\n\n  select\n    "項目",\n    '新北市申請戶數' as y_axis,\n    "修繕申請戶數" as data\n  from repair_subsidy_application_status_ntp\n  where "縣市" = '新北市'\n  \n  union all\n\n  select\n    "項目",\n    '新北市核定戶數' as y_axis,\n    "修繕核定戶數" as data\n  from repair_subsidy_application_status_ntp\n  where "縣市" = '新北市'\n) d\norder by x_axis, y_axis;	\N	metrotaipei
rent_level	\N	{1}	{\n  "mode": "byParam",\n  "byParam": {\n    "xParam": "TNAME",\n    "multi": true\n  }\n}	static	\N	\N	\N	內政部國土管理署	顯示雙北各行政區之租金水準	顯示雙北各行政區之租金水準，採用租金中位數呈現不同區域的租屋成本差異，協助使用者快速掌握各區租金分布情形，並以此評估生活居住成本。資料來源為內政部國土管理署「300 億元中央擴大租金補貼專案計畫」，統計範圍為截至 114 年 9 月 30 日之有效租賃契約，約 71.7 萬筆資料，並僅納入樣本數達 40 筆以上之行政區進行分析。	用於租屋與通勤決策分析，透過比較各行政區租金水準，搭配通勤時間或交通可達性，協助民眾在「時間成本」與「居住成本」之間取得平衡，選擇最適合的居住區域。另可進行城市治理與住宅政策分析，透過觀察各行政區租金分布差異，評估區域居住壓力與租屋市場結構，作為租金補貼政策、社會住宅規劃及都市發展決策之參考依據	{https://pip.moi.gov.tw/Publicize/Info/E1080}	{king}	2026-04-29 09:19:30.92388+00	2026-04-29 09:19:30.92388+00	two_d	SELECT \n  "行政區" AS x_axis,\n  "租金50分位數" AS data,\n  TO_CHAR("租金50分位數", 'FM999,999,999') AS label\nFROM public.rent_level\nWHERE "縣市" = '臺北市';	\N	taipei
social_housing	\N	{3}	\N	static	\N	\N	\N	內政部	呈現雙北各行政區社會住宅興辦進度與分布情形	展示臺北市與新北市各行政區社會住宅之興辦進度，依「已決標待開工」、「興建中」、「新完工」及「既有」等階段進行分類，呈現各區在不同進度階段的戶數分布情形。使用者可透過顏色與數值快速比較各行政區社會住宅的供給現況與建設進度，了解不同區域在興建推動上的差異，以及整體社會住宅政策的落實情形。上方亦提供總戶數統計，作為整體供給規模的參考。資料來源為內政部不動產相關資料，並依行政區與執行階段彙整呈現。	分析社會住宅資源在雙北各行政區的分布與發展狀況，例如觀察哪些區域已具備較高既有供給、哪些區域仍處於興建或規劃階段。民眾可藉此了解各區未來社會住宅供給潛力，作為居住選擇參考；政府與研究單位則可透過進度與區域分布分析，評估社會住宅政策推動是否均衡，並作為後續土地規劃、住宅政策調整及資源配置之依據。	{https://pip.moi.gov.tw/V3/B/SCRB0505.aspx?city=臺北市,https://pip.moi.gov.tw/V3/B/SCRB0505.aspx?city=新北市}	{king}	2026-04-30 05:56:00+00	2026-04-30 05:56:00+00	three_d	SELECT\n    d.行政區 AS x_axis,\n    s.執行情況 AS y_axis,\n    COUNT(t.執行情況) AS data\nFROM (\n    VALUES\n        ('北投區'), ('士林區'), ('內湖區'), ('南港區'), ('松山區'), ('信義區'),\n        ('中山區'), ('大同區'), ('中正區'), ('萬華區'), ('大安區'), ('文山區'),\n        ('新莊區'), ('淡水區'), ('汐止區'), ('板橋區'), ('三重區'), ('樹林區'),\n        ('土城區'), ('蘆洲區'), ('中和區'), ('永和區'), ('新店區'), ('鶯歌區'),\n        ('三峽區'), ('瑞芳區'), ('五股區'), ('泰山區'), ('林口區'), ('深坑區'),\n        ('石碇區'), ('坪林區'), ('三芝區'), ('石門區'), ('八里區'), ('平溪區'),\n        ('雙溪區'), ('貢寮區'), ('金山區'), ('萬里區'), ('烏來區')\n) AS d(行政區)\n\nCROSS JOIN (\n    VALUES\n        ('既有'),\n        ('新完工'),\n        ('興建中'),\n        ('已決標 待開工')\n) AS s(執行情況)\n\nLEFT JOIN social_housing_ntp t\n    ON t.行政區 = d.行政區\n    AND t.執行情況 = s.執行情況\n\nGROUP BY d.行政區, s.執行情況\n\nORDER BY\n    CASE d.行政區\n        WHEN '北投區' THEN 1\n        WHEN '士林區' THEN 2\n        WHEN '內湖區' THEN 3\n        WHEN '南港區' THEN 4\n        WHEN '松山區' THEN 5\n        WHEN '信義區' THEN 6\n        WHEN '中山區' THEN 7\n        WHEN '大同區' THEN 8\n        WHEN '中正區' THEN 9\n        WHEN '萬華區' THEN 10\n        WHEN '大安區' THEN 11\n        WHEN '文山區' THEN 12\n        WHEN '新莊區' THEN 13\n        WHEN '淡水區' THEN 14\n        WHEN '汐止區' THEN 15\n        WHEN '板橋區' THEN 16\n        WHEN '三重區' THEN 17\n        WHEN '樹林區' THEN 18\n        WHEN '土城區' THEN 19\n        WHEN '蘆洲區' THEN 20\n        WHEN '中和區' THEN 21\n        WHEN '永和區' THEN 22\n        WHEN '新店區' THEN 23\n        WHEN '鶯歌區' THEN 24\n        WHEN '三峽區' THEN 25\n        WHEN '瑞芳區' THEN 26\n        WHEN '五股區' THEN 27\n        WHEN '泰山區' THEN 28\n        WHEN '林口區' THEN 29\n        WHEN '深坑區' THEN 30\n        WHEN '石碇區' THEN 31\n        WHEN '坪林區' THEN 32\n        WHEN '三芝區' THEN 33\n        WHEN '石門區' THEN 34\n        WHEN '八里區' THEN 35\n        WHEN '平溪區' THEN 36\n        WHEN '雙溪區' THEN 37\n        WHEN '貢寮區' THEN 38\n        WHEN '金山區' THEN 39\n        WHEN '萬里區' THEN 40\n        WHEN '烏來區' THEN 41\n    END,\n    CASE s.執行情況\n        WHEN '既有' THEN 1\n        WHEN '新完工' THEN 2\n        WHEN '興建中' THEN 3\n        WHEN '已決標 待開工' THEN 4\n    END;	\N	metrotaipei
purchase_subsidy_application_status	\N	\N	\N	static	\N	\N	\N	都發局	呈現臺北市自購住宅貸款利息補貼申請與核定戶數的歷年變化趨勢	展示臺北市自購住宅貸款利息補貼之「申請戶數」與「核定戶數」歷年變化情形，透過折線圖呈現不同城市與指標的趨勢走向。使用者可比較兩市在各年度的申請需求與實際核定情形，觀察補貼資源配置與核定量能之變化，並進一步分析申請與核定之間的差距，了解住宅金融補助政策對購屋族群的支持程度。\n\n需注意，臺北市相關資料僅統計至2022年，後續年度暫無資料，進行跨年度或跨城市比較時應留意資料完整性差異。	用於評估住宅補貼政策對購屋族群的支持效果，例如觀察申請戶數上升是否代表購屋壓力增加，或核定戶數變化是否反映政策調整方向。民眾可透過此趨勢了解補貼申請競爭程度與歷年變化，作為購屋與申請補助的參考；政府與研究單位則可透過雙北比較與長期趨勢分析，檢視補貼政策是否有效回應市場需求，並作為住宅政策與金融支持措施優化之依據。	{https://data.taipei/dataset/detail?id=6297943a-1e71-480d-967c-635855df66fe}	{king}	2026-04-30 05:56:00+00	2026-04-30 05:56:00+00	time	select\n  to_date("項目"::text || '-01-01', 'YYYY-MM-DD') as x_axis,\n  y_axis,\n  data\nfrom (\n  select\n    "項目",\n    '臺北市申請戶數' as y_axis,\n    "購買申請戶數" as data\n  from purchase_subsidy_application_status_tp\n  where "縣市" = '臺北市'\n\n  union all\n\n  select\n    "項目",\n    '臺北市核定戶數' as y_axis,\n    "購買核定戶數" as data\n  from purchase_subsidy_application_status_tp\n  where "縣市" = '臺北市'\n) d\norder by x_axis, y_axis;	\N	taipei
repair_subsidy_application_status	\N	\N	\N	static	\N	\N	\N	都發局	呈現臺北市修繕住宅貸款利息補貼申請與核定戶數的歷年變化趨勢	展示臺北市修繕住宅貸款利息補貼之「申請戶數」與「核定戶數」歷年變化情形，透過折線圖呈現不同城市與指標的趨勢走向。使用者可比較兩市在各年度的申請需求與實際核定情形，觀察補貼資源配置與核定量能之變化，並進一步分析申請與核定之間的差距，了解住宅修繕補助政策對既有住宅改善的支持程度。\n\n需注意，臺北市相關資料僅統計至2022年，後續年度暫無資料，進行跨年度或跨城市比較時應留意資料完整性差異。	可用於評估住宅修繕補貼政策之推動成效，例如觀察申請戶數變化是否反映老屋修繕需求增減，或核定戶數趨勢是否代表政府資源投入程度。民眾可透過此趨勢了解補貼申請情形，作為是否進行住宅修繕與申請補助的參考；政府與研究單位則可透過雙北比較與長期趨勢分析，檢視補助政策是否有效回應住宅老化問題，並作為未來住宅改善與居住品質提升政策之依據。	{https://data.taipei/dataset/detail?id=6297943a-1e71-480d-967c-635855df66fe}	{king}	2026-04-30 05:56:00+00	2026-04-30 05:56:00+00	time	select\n  to_date("項目"::text || '-01-01', 'YYYY-MM-DD') as x_axis,\n  y_axis,\n  data\nfrom (\n  select\n    "項目",\n    '臺北市申請戶數' as y_axis,\n    "修繕申請戶數" as data\n  from repair_subsidy_application_status_tp\n  where "縣市" = '臺北市'\n\n  union all\n\n  select\n    "項目",\n    '臺北市核定戶數' as y_axis,\n    "修繕核定戶數" as data\n  from repair_subsidy_application_status_tp\n  where "縣市" = '臺北市'\n) d\norder by x_axis, y_axis;	\N	taipei
bike_network	\N	{100,101}	{\n  "mode": "byParam",\n  "byParam": {\n    "xParam": "direction"\n  }\n}	static	\N	\N	\N	交通局交工處	顯示雙北當前自行車路網分布。	顯示雙北當前自行車路網分布。雙北擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，雙北政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。	使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。	{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/NewTaipei?%24top=30&%24format=JSON}	{doit,ntpc}	2023-12-20 05:56:00+00	2024-01-11 06:26:02.069+00	two_d	select x_axis,sum(data)data from (select  direction as x_axis ,round(sum(cycling_length)/1000) as data\r\nfrom public.bike_network_tpe  \r\ngroup by direction\r\nunion all\r\nselect  direction as x_axis ,round(sum(cycling_length)/1000) as data\r\nfrom public.bike_network_new_tpe  \r\ngroup by direction\r\n)d\r\nwhere x_axis !=''\r\ngroup by x_axis	\N	metrotaipei
social_housing	\N	{3}	[\n  "==",\n  ["get", "縣市"],\n  "臺北市"\n]	static	\N	\N	\N	內政部	呈現臺北各行政區社會住宅興辦進度與分布情形	展示臺北市各行政區社會住宅之興辦進度，依「已決標待開工」、「興建中」、「新完工」及「既有」等階段進行分類，呈現各區在不同進度階段的戶數分布情形。使用者可透過顏色與數值快速比較各行政區社會住宅的供給現況與建設進度，了解不同區域在興建推動上的差異，以及整體社會住宅政策的落實情形。上方亦提供總戶數統計，作為整體供給規模的參考。資料來源為內政部不動產相關資料，並依行政區與執行階段彙整呈現。	分析社會住宅資源在臺北各行政區的分布與發展狀況，例如觀察哪些區域已具備較高既有供給、哪些區域仍處於興建或規劃階段。民眾可藉此了解各區未來社會住宅供給潛力，作為居住選擇參考；政府與研究單位則可透過進度與區域分布分析，評估社會住宅政策推動是否均衡，並作為後續土地規劃、住宅政策調整及資源配置之依據。	{https://pip.moi.gov.tw/V3/B/SCRB0505.aspx?city=臺北市}	{king}	2026-04-30 05:56:00+00	2026-04-30 05:56:00+00	three_d	SELECT\n    d.行政區 AS x_axis,\n    s.執行情況 AS y_axis,\n    COUNT(t.執行情況) AS data\nFROM (\n    VALUES\n        ('北投區'), ('士林區'), ('內湖區'), ('南港區'), ('松山區'), ('信義區'),\n        ('中山區'), ('大同區'), ('中正區'), ('萬華區'), ('大安區'), ('文山區')\n) AS d(行政區)\n\nCROSS JOIN (\n    VALUES\n        ('既有'),\n        ('新完工'),\n        ('興建中'),\n        ('已決標 待開工')\n) AS s(執行情況)\n\nLEFT JOIN social_housing_tp t\n    ON t.行政區 = d.行政區\n    AND t.執行情況 = s.執行情況\n\nGROUP BY d.行政區, s.執行情況\n\nORDER BY\n    CASE d.行政區\n        WHEN '北投區' THEN 1\n        WHEN '士林區' THEN 2\n        WHEN '內湖區' THEN 3\n        WHEN '南港區' THEN 4\n        WHEN '松山區' THEN 5\n        WHEN '信義區' THEN 6\n        WHEN '中山區' THEN 7\n        WHEN '大同區' THEN 8\n        WHEN '中正區' THEN 9\n        WHEN '萬華區' THEN 10\n        WHEN '大安區' THEN 11\n        WHEN '文山區' THEN 12\n    END,\n    CASE s.執行情況\n        WHEN '既有' THEN 1\n        WHEN '新完工' THEN 2\n        WHEN '興建中' THEN 3\n        WHEN '已決標 待開工' THEN 4\n    END;	\N	taipei
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, access_control, modify, read) FROM stdin;
1	admin	t	t	t
2	editor	f	t	t
3	viewer	f	f	t
4	admin	t	t	t
5	editor	f	t	t
6	viewer	f	f	t
7	admin	t	t	t
8	editor	f	t	t
9	viewer	f	f	t
10	admin	t	t	t
11	editor	f	t	t
12	viewer	f	f	t
13	admin	t	t	t
14	editor	f	t	t
15	viewer	f	f	t
16	admin	t	t	t
17	editor	f	t	t
18	viewer	f	f	t
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: view_points; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.view_points (id, user_id, center_x, center_y, zoom, pitch, bearing, name, point_type) FROM stdin;
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: ai_chatlog_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ai_chatlog_id_seq', 1, false);


--
-- Name: auth_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_users_id_seq', 6, true);


--
-- Name: chat_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_logs_id_seq', 1, false);


--
-- Name: component_maps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.component_maps_id_seq', 3, true);


--
-- Name: components_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.components_id_seq', 6, true);


--
-- Name: contributors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contributors_id_seq', 1, false);


--
-- Name: dashboards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dashboards_id_seq', 362, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_seq', 5, true);


--
-- Name: incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incidents_id_seq', 1, false);


--
-- Name: issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.issues_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 18, true);


--
-- Name: view_points_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.view_points_id_seq', 1, false);


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: postgres
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: ai_chatlog ai_chatlog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_chatlog
    ADD CONSTRAINT ai_chatlog_pkey PRIMARY KEY (id);


--
-- Name: auth_user_group_roles auth_user_group_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_group_roles
    ADD CONSTRAINT auth_user_group_roles_pkey PRIMARY KEY (auth_user_id, group_id, role_id);


--
-- Name: auth_users auth_users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users
    ADD CONSTRAINT auth_users_email_key UNIQUE (email);


--
-- Name: auth_users auth_users_idno_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users
    ADD CONSTRAINT auth_users_idno_key UNIQUE (idno);


--
-- Name: auth_users auth_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users
    ADD CONSTRAINT auth_users_pkey PRIMARY KEY (id);


--
-- Name: auth_users auth_users_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_users
    ADD CONSTRAINT auth_users_uuid_key UNIQUE (uuid);


--
-- Name: chat_logs chat_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_logs
    ADD CONSTRAINT chat_logs_pkey PRIMARY KEY (id);


--
-- Name: component_charts component_charts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component_charts
    ADD CONSTRAINT component_charts_pkey PRIMARY KEY (index);


--
-- Name: component_maps component_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component_maps
    ADD CONSTRAINT component_maps_pkey PRIMARY KEY (id);


--
-- Name: components components_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.components
    ADD CONSTRAINT components_index_key UNIQUE (index);


--
-- Name: components components_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.components
    ADD CONSTRAINT components_pkey PRIMARY KEY (id);


--
-- Name: contributors contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contributors
    ADD CONSTRAINT contributors_pkey PRIMARY KEY (id);


--
-- Name: dashboard_groups dashboard_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_groups
    ADD CONSTRAINT dashboard_groups_pkey PRIMARY KEY (dashboard_id, group_id);


--
-- Name: dashboards dashboards_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboards
    ADD CONSTRAINT dashboards_index_key UNIQUE (index);


--
-- Name: dashboards dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboards
    ADD CONSTRAINT dashboards_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: query_charts query_charts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.query_charts
    ADD CONSTRAINT query_charts_pkey PRIMARY KEY (index, city);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: view_points view_points_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.view_points
    ADD CONSTRAINT view_points_pkey PRIMARY KEY (id);


--
-- Name: idx_ai_chatlog_session; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_chatlog_session ON public.ai_chatlog USING btree (session_id);


--
-- Name: idx_ai_chatlog_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_chatlog_user ON public.ai_chatlog USING btree (user_id);


--
-- Name: auth_user_group_roles fk_auth_user_group_roles_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_group_roles
    ADD CONSTRAINT fk_auth_user_group_roles_auth_user FOREIGN KEY (auth_user_id) REFERENCES public.auth_users(id);


--
-- Name: auth_user_group_roles fk_auth_user_group_roles_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_group_roles
    ADD CONSTRAINT fk_auth_user_group_roles_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: auth_user_group_roles fk_auth_user_group_roles_role; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_group_roles
    ADD CONSTRAINT fk_auth_user_group_roles_role FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: dashboard_groups fk_dashboard_groups_dashboard; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_groups
    ADD CONSTRAINT fk_dashboard_groups_dashboard FOREIGN KEY (dashboard_id) REFERENCES public.dashboards(id);


--
-- Name: dashboard_groups fk_dashboard_groups_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_groups
    ADD CONSTRAINT fk_dashboard_groups_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: groups fk_groups_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_groups_auth_user FOREIGN KEY (create_by) REFERENCES public.auth_users(id);


--
-- Name: view_points fk_view_points_auth_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.view_points
    ADD CONSTRAINT fk_view_points_auth_user FOREIGN KEY (user_id) REFERENCES public.auth_users(id);


--
-- PostgreSQL database dump complete
--

