--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

-- Started on 2023-12-15 13:47:17

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 214 (class 1259 OID 19487)
-- Name: hourly_price; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hourly_price (
    timeslot timestamp with time zone NOT NULL,
    price double precision NOT NULL
);


ALTER TABLE public.hourly_price OWNER TO postgres;

--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE hourly_price; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.hourly_price IS 'Electricity prices by hour';


--
-- TOC entry 220 (class 1259 OID 32796)
-- Name: average_by_weekday_num; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.average_by_weekday_num AS
 SELECT EXTRACT(isodow FROM hourly_price.timeslot) AS vpnumero,
    avg(hourly_price.price) AS avg
   FROM public.hourly_price
  GROUP BY (EXTRACT(isodow FROM hourly_price.timeslot))
  ORDER BY (EXTRACT(isodow FROM hourly_price.timeslot));


ALTER TABLE public.average_by_weekday_num OWNER TO postgres;

--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 220
-- Name: VIEW average_by_weekday_num; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.average_by_weekday_num IS 'Calculates an average for each weekday using ISO-weekday numbers';


--
-- TOC entry 216 (class 1259 OID 32775)
-- Name: average_by_year; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.average_by_year AS
 SELECT EXTRACT(year FROM hourly_price.timeslot) AS vuosi,
    avg(hourly_price.price) AS keskihinta
   FROM public.hourly_price
  GROUP BY (EXTRACT(year FROM hourly_price.timeslot));


ALTER TABLE public.average_by_year OWNER TO postgres;

--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 216
-- Name: VIEW average_by_year; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.average_by_year IS 'Average electricity prices on yearly basis';


--
-- TOC entry 217 (class 1259 OID 32783)
-- Name: average_by_year_and_month; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.average_by_year_and_month AS
 SELECT EXTRACT(year FROM hourly_price.timeslot) AS vuosi,
    EXTRACT(month FROM hourly_price.timeslot) AS kuukausi,
    avg(hourly_price.price) AS keskihinta,
    stddev_pop(hourly_price.price) AS hajonta,
    (avg(hourly_price.price) + stddev_pop(hourly_price.price)) AS "yläraja",
    (avg(hourly_price.price) - stddev_pop(hourly_price.price)) AS alaraja
   FROM public.hourly_price
  GROUP BY (EXTRACT(year FROM hourly_price.timeslot)), (EXTRACT(month FROM hourly_price.timeslot));


ALTER TABLE public.average_by_year_and_month OWNER TO postgres;

--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 217
-- Name: VIEW average_by_year_and_month; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.average_by_year_and_month IS 'Calculates average electricity prices for year-month basis';


--
-- TOC entry 218 (class 1259 OID 32787)
-- Name: average_by_year_month_day; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.average_by_year_month_day AS
 SELECT EXTRACT(year FROM hourly_price.timeslot) AS vuosi,
    EXTRACT(month FROM hourly_price.timeslot) AS kuukausi,
    EXTRACT(day FROM hourly_price.timeslot) AS "päivä",
    avg(hourly_price.price) AS keskihinta
   FROM public.hourly_price
  GROUP BY (EXTRACT(year FROM hourly_price.timeslot)), (EXTRACT(month FROM hourly_price.timeslot)), (EXTRACT(day FROM hourly_price.timeslot));


ALTER TABLE public.average_by_year_month_day OWNER TO postgres;

--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 218
-- Name: VIEW average_by_year_month_day; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.average_by_year_month_day IS 'Calculates averages to day level';


--
-- TOC entry 219 (class 1259 OID 32791)
-- Name: weekday_lookup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weekday_lookup (
    weekday_number integer NOT NULL,
    fin_name character varying(20) NOT NULL,
    swe_name character varying(20) NOT NULL,
    eng_name character varying(20) NOT NULL,
    ger_name character varying(20) NOT NULL,
    tur_name character varying(20) NOT NULL
);


ALTER TABLE public.weekday_lookup OWNER TO postgres;

--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE weekday_lookup; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.weekday_lookup IS 'Allows weekday lookup with several languages';


--
-- TOC entry 221 (class 1259 OID 32804)
-- Name: avg_price_by_weekday_name; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.avg_price_by_weekday_name AS
 SELECT weekday_lookup.fin_name AS "viikonpäivä",
    weekday_lookup.swe_name AS veckodag,
    weekday_lookup.eng_name AS weekday,
    weekday_lookup.ger_name AS wochentag,
    weekday_lookup.tur_name AS haftaici,
    round((average_by_weekday_num.avg)::numeric, 3) AS keskihinta
   FROM public.weekday_lookup,
    public.average_by_weekday_num
  WHERE ((weekday_lookup.weekday_number)::numeric = average_by_weekday_num.vpnumero)
  ORDER BY average_by_weekday_num.vpnumero;


ALTER TABLE public.avg_price_by_weekday_name OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 32771)
-- Name: current_prices; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.current_prices AS
 SELECT hourly_price.timeslot AS kello,
    hourly_price.price AS hinta
   FROM public.hourly_price
  WHERE (hourly_price.timeslot >= now())
  ORDER BY hourly_price.timeslot;


ALTER TABLE public.current_prices OWNER TO postgres;

--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 215
-- Name: VIEW current_prices; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.current_prices IS 'Shows electricity prices from now on';


--
-- TOC entry 228 (class 1259 OID 245871)
-- Name: observation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.observation (
    "timestamp" time with time zone NOT NULL,
    place character varying(50) NOT NULL,
    wind_speed real,
    wind_direction real,
    temperature real
);


ALTER TABLE public.observation OWNER TO postgres;

--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE observation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.observation IS 'Stores FMI weather observtions in 10 minute intervals';


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation."timestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.observation."timestamp" IS 'ISO timestamp with timezone';


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN observation.place; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.observation.place IS 'Name of weather station';


--
-- TOC entry 230 (class 1259 OID 286933)
-- Name: current_weather; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.current_weather AS
 SELECT observation.temperature AS "lampötila",
    observation.wind_speed AS tuuli,
    observation.wind_direction AS suunta
   FROM public.observation
  ORDER BY observation."timestamp" DESC
 LIMIT 1;


ALTER TABLE public.current_weather OWNER TO postgres;

--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 230
-- Name: VIEW current_weather; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.current_weather IS 'Current weather observations';


--
-- TOC entry 229 (class 1259 OID 286830)
-- Name: forecast; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.forecast (
    "timestamp" timestamp with time zone NOT NULL,
    place character varying(50) NOT NULL,
    wind_speed real,
    wind_direction real,
    temperature real
);


ALTER TABLE public.forecast OWNER TO postgres;

--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE forecast; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.forecast IS 'FMI weather forecast for 36 hours';


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN forecast."timestamp"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.forecast."timestamp" IS 'ISO timestamp with timezone';


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN forecast.place; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.forecast.place IS 'Name of weather station';


--
-- TOC entry 226 (class 1259 OID 163877)
-- Name: hourly_page; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.hourly_page AS
 SELECT EXTRACT(day FROM hourly_price.timeslot) AS day,
    EXTRACT(hour FROM hourly_price.timeslot) AS "time",
    hourly_price.price
   FROM public.hourly_price
  WHERE (hourly_price.timeslot >= now());


ALTER TABLE public.hourly_page OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 286937)
-- Name: latest_forecasts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.latest_forecasts AS
 SELECT forecast."timestamp",
    forecast.place,
    forecast.wind_speed,
    forecast.wind_direction,
    forecast.temperature
   FROM public.forecast
  WHERE (forecast."timestamp" >= now());


ALTER TABLE public.latest_forecasts OWNER TO postgres;

--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 231
-- Name: VIEW latest_forecasts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.latest_forecasts IS 'Forecasts from now on ';


--
-- TOC entry 223 (class 1259 OID 40967)
-- Name: month_name_lookup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.month_name_lookup (
    month_number integer NOT NULL,
    fin_name character varying(20) NOT NULL,
    swe_name character varying(20),
    eng_name character varying(20),
    ger_name character varying(20),
    tur_name character varying(20)
);


ALTER TABLE public.month_name_lookup OWNER TO postgres;

--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE month_name_lookup; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.month_name_lookup IS 'Gives a month name by number';


--
-- TOC entry 224 (class 1259 OID 40980)
-- Name: monthly_averages_by_year_fin; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.monthly_averages_by_year_fin AS
 SELECT average_by_year_and_month.vuosi,
    month_name_lookup.fin_name,
    average_by_year_and_month.keskihinta
   FROM public.average_by_year_and_month,
    public.month_name_lookup
  WHERE (average_by_year_and_month.kuukausi = (month_name_lookup.month_number)::numeric)
  ORDER BY average_by_year_and_month.vuosi, average_by_year_and_month.kuukausi;


ALTER TABLE public.monthly_averages_by_year_fin OWNER TO postgres;

--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 224
-- Name: VIEW monthly_averages_by_year_fin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.monthly_averages_by_year_fin IS 'Monthly averages with Finnish month names';


--
-- TOC entry 225 (class 1259 OID 122911)
-- Name: previous_month_average; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.previous_month_average AS
 SELECT average_by_year_and_month.keskihinta
   FROM public.average_by_year_and_month
  WHERE ((average_by_year_and_month.vuosi = EXTRACT(year FROM now())) AND (average_by_year_and_month.kuukausi = (EXTRACT(month FROM now()) - (1)::numeric)));


ALTER TABLE public.previous_month_average OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 172069)
-- Name: previous_month_average2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.previous_month_average2 AS
 SELECT average_by_year_and_month.keskihinta,
    average_by_year_and_month."yläraja",
    average_by_year_and_month.alaraja
   FROM public.average_by_year_and_month
  WHERE ((average_by_year_and_month.vuosi = EXTRACT(year FROM now())) AND (average_by_year_and_month.kuukausi = (EXTRACT(month FROM now()) - (1)::numeric)));


ALTER TABLE public.previous_month_average2 OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 40963)
-- Name: running_average_stddev; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.running_average_stddev AS
 SELECT avg(hourly_price.price) AS hinta,
    stddev(hourly_price.price) AS keskihajonta
   FROM public.hourly_price;


ALTER TABLE public.running_average_stddev OWNER TO postgres;

--
-- TOC entry 3461 (class 0 OID 0)
-- Dependencies: 222
-- Name: VIEW running_average_stddev; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW public.running_average_stddev IS 'Calculates  average electricity price and standard deviation from whole price data';


--
-- TOC entry 232 (class 1259 OID 295012)
-- Name: temperature_observation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.temperature_observation (
    "timestamp" timestamp with time zone NOT NULL,
    temperature real,
    place character varying(80) NOT NULL
);


ALTER TABLE public.temperature_observation OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 295027)
-- Name: weather_station; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_station (
    place character varying(80) NOT NULL,
    fmi_sid character varying,
    lat real,
    lon real
);


ALTER TABLE public.weather_station OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 295022)
-- Name: wind_direction_observation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wind_direction_observation (
    "timestamp" timestamp with time zone NOT NULL,
    wind_direction real,
    place character varying(80) NOT NULL
);


ALTER TABLE public.wind_direction_observation OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 295017)
-- Name: wind_speed_observation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wind_speed_observation (
    "timestamp" timestamp with time zone NOT NULL,
    wind_speed real,
    place character varying(80) NOT NULL
);


ALTER TABLE public.wind_speed_observation OWNER TO postgres;

--
-- TOC entry 3434 (class 0 OID 286830)
-- Dependencies: 229
-- Data for Name: forecast; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3430 (class 0 OID 19487)
-- Dependencies: 214
-- Data for Name: hourly_price; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.hourly_price VALUES ('2023-03-23 03:00:00+02', 1.09);
INSERT INTO public.hourly_price VALUES ('2023-03-23 04:00:00+02', 0.55);
INSERT INTO public.hourly_price VALUES ('2023-03-23 05:00:00+02', 0.45);
INSERT INTO public.hourly_price VALUES ('2023-03-23 06:00:00+02', 0.45);
INSERT INTO public.hourly_price VALUES ('2023-03-23 07:00:00+02', 0.97);
INSERT INTO public.hourly_price VALUES ('2023-03-23 08:00:00+02', 2.59);
INSERT INTO public.hourly_price VALUES ('2023-03-23 09:00:00+02', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-03-23 10:00:00+02', 4.24);
INSERT INTO public.hourly_price VALUES ('2023-03-23 11:00:00+02', 4.83);
INSERT INTO public.hourly_price VALUES ('2023-03-23 12:00:00+02', 4.58);
INSERT INTO public.hourly_price VALUES ('2023-03-23 13:00:00+02', 4.37);
INSERT INTO public.hourly_price VALUES ('2023-03-23 14:00:00+02', 3.92);
INSERT INTO public.hourly_price VALUES ('2023-03-23 15:00:00+02', 3.92);
INSERT INTO public.hourly_price VALUES ('2023-03-23 16:00:00+02', 3.99);
INSERT INTO public.hourly_price VALUES ('2023-03-23 17:00:00+02', 4.58);
INSERT INTO public.hourly_price VALUES ('2023-03-23 18:00:00+02', 4.72);
INSERT INTO public.hourly_price VALUES ('2023-03-23 19:00:00+02', 5.06);
INSERT INTO public.hourly_price VALUES ('2023-03-23 20:00:00+02', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-03-23 21:00:00+02', 7.15);
INSERT INTO public.hourly_price VALUES ('2023-03-23 22:00:00+02', 6.28);
INSERT INTO public.hourly_price VALUES ('2023-03-23 23:00:00+02', 5.26);
INSERT INTO public.hourly_price VALUES ('2023-03-24 00:00:00+02', 4.94);
INSERT INTO public.hourly_price VALUES ('2023-03-24 01:00:00+02', 4.6);
INSERT INTO public.hourly_price VALUES ('2023-03-24 03:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-03-24 04:00:00+03', 3.66);
INSERT INTO public.hourly_price VALUES ('2023-03-24 05:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-03-24 06:00:00+03', 3.33);
INSERT INTO public.hourly_price VALUES ('2023-03-24 07:00:00+03', 3.41);
INSERT INTO public.hourly_price VALUES ('2023-03-24 08:00:00+03', 3.73);
INSERT INTO public.hourly_price VALUES ('2023-03-24 09:00:00+03', 4.31);
INSERT INTO public.hourly_price VALUES ('2023-03-24 10:00:00+03', 4.93);
INSERT INTO public.hourly_price VALUES ('2023-03-24 11:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-03-24 12:00:00+03', 8.37);
INSERT INTO public.hourly_price VALUES ('2023-03-24 13:00:00+03', 6.47);
INSERT INTO public.hourly_price VALUES ('2023-03-24 14:00:00+03', 4.4);
INSERT INTO public.hourly_price VALUES ('2023-03-24 15:00:00+03', 3.76);
INSERT INTO public.hourly_price VALUES ('2023-03-24 16:00:00+03', 4.01);
INSERT INTO public.hourly_price VALUES ('2023-03-24 17:00:00+03', 3.27);
INSERT INTO public.hourly_price VALUES ('2023-03-24 18:00:00+03', 3.38);
INSERT INTO public.hourly_price VALUES ('2023-03-24 19:00:00+03', 3.3);
INSERT INTO public.hourly_price VALUES ('2023-03-24 20:00:00+03', 4.22);
INSERT INTO public.hourly_price VALUES ('2023-03-24 21:00:00+03', 5.49);
INSERT INTO public.hourly_price VALUES ('2023-03-24 22:00:00+03', 5.56);
INSERT INTO public.hourly_price VALUES ('2023-03-24 23:00:00+03', 4.93);
INSERT INTO public.hourly_price VALUES ('2023-03-25 00:00:00+03', 4.39);
INSERT INTO public.hourly_price VALUES ('2023-03-25 01:00:00+03', 4.19);
INSERT INTO public.hourly_price VALUES ('2023-03-25 02:00:00+03', 3.72);
INSERT INTO public.hourly_price VALUES ('2023-03-25 03:00:00+03', 3.26);
INSERT INTO public.hourly_price VALUES ('2023-03-25 04:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-03-25 05:00:00+03', 0.72);
INSERT INTO public.hourly_price VALUES ('2023-03-25 06:00:00+03', 0.33);
INSERT INTO public.hourly_price VALUES ('2023-03-25 07:00:00+03', 0.23);
INSERT INTO public.hourly_price VALUES ('2023-03-25 08:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-03-25 09:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-03-25 10:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-03-25 11:00:00+03', 2.53);
INSERT INTO public.hourly_price VALUES ('2023-03-25 12:00:00+03', 2.79);
INSERT INTO public.hourly_price VALUES ('2023-03-25 13:00:00+03', 3.14);
INSERT INTO public.hourly_price VALUES ('2023-03-25 14:00:00+03', 3.13);
INSERT INTO public.hourly_price VALUES ('2023-03-25 15:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-03-25 16:00:00+03', 3.08);
INSERT INTO public.hourly_price VALUES ('2023-03-25 17:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-03-25 18:00:00+03', 3.25);
INSERT INTO public.hourly_price VALUES ('2023-03-25 19:00:00+03', 3.98);
INSERT INTO public.hourly_price VALUES ('2023-03-25 20:00:00+03', 4.47);
INSERT INTO public.hourly_price VALUES ('2023-03-25 21:00:00+03', 4.79);
INSERT INTO public.hourly_price VALUES ('2023-03-25 22:00:00+03', 6.6);
INSERT INTO public.hourly_price VALUES ('2023-03-25 23:00:00+03', 7.05);
INSERT INTO public.hourly_price VALUES ('2023-03-26 00:00:00+03', 6.31);
INSERT INTO public.hourly_price VALUES ('2023-03-26 01:00:00+03', 4.6);
INSERT INTO public.hourly_price VALUES ('2023-03-26 02:00:00+03', 4.28);
INSERT INTO public.hourly_price VALUES ('2023-03-26 03:00:00+03', 3.67);
INSERT INTO public.hourly_price VALUES ('2023-03-26 04:00:00+03', 4.36);
INSERT INTO public.hourly_price VALUES ('2023-03-26 05:00:00+03', 4.32);
INSERT INTO public.hourly_price VALUES ('2023-03-26 06:00:00+03', 4.41);
INSERT INTO public.hourly_price VALUES ('2023-03-26 07:00:00+03', 4.5);
INSERT INTO public.hourly_price VALUES ('2023-03-26 08:00:00+03', 4.45);
INSERT INTO public.hourly_price VALUES ('2023-03-26 09:00:00+03', 4.51);
INSERT INTO public.hourly_price VALUES ('2023-03-26 10:00:00+03', 4.59);
INSERT INTO public.hourly_price VALUES ('2023-03-26 11:00:00+03', 4.77);
INSERT INTO public.hourly_price VALUES ('2023-03-26 12:00:00+03', 5.24);
INSERT INTO public.hourly_price VALUES ('2023-03-26 13:00:00+03', 5.46);
INSERT INTO public.hourly_price VALUES ('2023-03-26 14:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-03-26 15:00:00+03', 5.1);
INSERT INTO public.hourly_price VALUES ('2023-03-26 16:00:00+03', 4.76);
INSERT INTO public.hourly_price VALUES ('2023-03-26 17:00:00+03', 4.87);
INSERT INTO public.hourly_price VALUES ('2023-03-26 18:00:00+03', 4.74);
INSERT INTO public.hourly_price VALUES ('2023-03-26 19:00:00+03', 5.32);
INSERT INTO public.hourly_price VALUES ('2023-03-26 20:00:00+03', 6.86);
INSERT INTO public.hourly_price VALUES ('2023-03-26 21:00:00+03', 6.82);
INSERT INTO public.hourly_price VALUES ('2023-03-26 22:00:00+03', 6.03);
INSERT INTO public.hourly_price VALUES ('2023-03-26 23:00:00+03', 5.01);
INSERT INTO public.hourly_price VALUES ('2023-03-27 00:00:00+03', 4.86);
INSERT INTO public.hourly_price VALUES ('2023-03-27 01:00:00+03', 4.5);
INSERT INTO public.hourly_price VALUES ('2023-03-27 02:00:00+03', 4.3);
INSERT INTO public.hourly_price VALUES ('2023-03-27 03:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-03-27 04:00:00+03', 4.63);
INSERT INTO public.hourly_price VALUES ('2023-03-27 05:00:00+03', 4.43);
INSERT INTO public.hourly_price VALUES ('2023-03-27 06:00:00+03', 4.39);
INSERT INTO public.hourly_price VALUES ('2023-03-27 07:00:00+03', 4.42);
INSERT INTO public.hourly_price VALUES ('2023-03-27 08:00:00+03', 4.57);
INSERT INTO public.hourly_price VALUES ('2023-03-27 09:00:00+03', 4.82);
INSERT INTO public.hourly_price VALUES ('2023-03-27 10:00:00+03', 5.94);
INSERT INTO public.hourly_price VALUES ('2023-03-27 11:00:00+03', 6.96);
INSERT INTO public.hourly_price VALUES ('2023-03-27 12:00:00+03', 8.25);
INSERT INTO public.hourly_price VALUES ('2023-03-27 13:00:00+03', 10.76);
INSERT INTO public.hourly_price VALUES ('2023-03-27 14:00:00+03', 10.18);
INSERT INTO public.hourly_price VALUES ('2023-03-27 15:00:00+03', 8.9);
INSERT INTO public.hourly_price VALUES ('2023-03-27 16:00:00+03', 7.51);
INSERT INTO public.hourly_price VALUES ('2023-03-27 17:00:00+03', 6.04);
INSERT INTO public.hourly_price VALUES ('2023-03-27 18:00:00+03', 4.72);
INSERT INTO public.hourly_price VALUES ('2023-03-27 19:00:00+03', 5.06);
INSERT INTO public.hourly_price VALUES ('2023-03-27 20:00:00+03', 5.46);
INSERT INTO public.hourly_price VALUES ('2023-03-27 21:00:00+03', 7.76);
INSERT INTO public.hourly_price VALUES ('2023-03-27 22:00:00+03', 7.36);
INSERT INTO public.hourly_price VALUES ('2023-03-27 23:00:00+03', 6.59);
INSERT INTO public.hourly_price VALUES ('2023-03-28 00:00:00+03', 5.49);
INSERT INTO public.hourly_price VALUES ('2023-03-28 01:00:00+03', 5.24);
INSERT INTO public.hourly_price VALUES ('2023-03-28 02:00:00+03', 4.71);
INSERT INTO public.hourly_price VALUES ('2023-03-28 03:00:00+03', 4.44);
INSERT INTO public.hourly_price VALUES ('2023-03-28 04:00:00+03', 3.17);
INSERT INTO public.hourly_price VALUES ('2023-03-28 05:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-03-28 06:00:00+03', 3.19);
INSERT INTO public.hourly_price VALUES ('2023-03-28 07:00:00+03', 3.25);
INSERT INTO public.hourly_price VALUES ('2023-03-28 08:00:00+03', 3.5);
INSERT INTO public.hourly_price VALUES ('2023-03-28 09:00:00+03', 4.42);
INSERT INTO public.hourly_price VALUES ('2023-03-28 10:00:00+03', 4.18);
INSERT INTO public.hourly_price VALUES ('2023-03-28 11:00:00+03', 4.61);
INSERT INTO public.hourly_price VALUES ('2023-03-28 12:00:00+03', 5.68);
INSERT INTO public.hourly_price VALUES ('2023-03-28 13:00:00+03', 5.4);
INSERT INTO public.hourly_price VALUES ('2023-03-28 14:00:00+03', 5.72);
INSERT INTO public.hourly_price VALUES ('2023-03-28 15:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-03-28 16:00:00+03', 5.46);
INSERT INTO public.hourly_price VALUES ('2023-03-28 17:00:00+03', 4.84);
INSERT INTO public.hourly_price VALUES ('2023-03-28 18:00:00+03', 4.73);
INSERT INTO public.hourly_price VALUES ('2023-03-28 19:00:00+03', 4.76);
INSERT INTO public.hourly_price VALUES ('2023-03-28 20:00:00+03', 5.21);
INSERT INTO public.hourly_price VALUES ('2023-03-28 21:00:00+03', 5.58);
INSERT INTO public.hourly_price VALUES ('2023-03-28 22:00:00+03', 5.27);
INSERT INTO public.hourly_price VALUES ('2023-03-28 23:00:00+03', 5.71);
INSERT INTO public.hourly_price VALUES ('2023-03-29 00:00:00+03', 4.88);
INSERT INTO public.hourly_price VALUES ('2023-03-29 01:00:00+03', 5.01);
INSERT INTO public.hourly_price VALUES ('2023-03-29 02:00:00+03', 4.92);
INSERT INTO public.hourly_price VALUES ('2023-03-29 03:00:00+03', 4.59);
INSERT INTO public.hourly_price VALUES ('2023-03-29 04:00:00+03', 5.88);
INSERT INTO public.hourly_price VALUES ('2023-03-29 05:00:00+03', 5.71);
INSERT INTO public.hourly_price VALUES ('2023-03-29 06:00:00+03', 5.8);
INSERT INTO public.hourly_price VALUES ('2023-03-29 07:00:00+03', 5.88);
INSERT INTO public.hourly_price VALUES ('2023-03-29 08:00:00+03', 6.3);
INSERT INTO public.hourly_price VALUES ('2023-03-29 09:00:00+03', 7.19);
INSERT INTO public.hourly_price VALUES ('2023-03-29 10:00:00+03', 11.88);
INSERT INTO public.hourly_price VALUES ('2023-03-29 11:00:00+03', 15.39);
INSERT INTO public.hourly_price VALUES ('2023-03-29 12:00:00+03', 16.23);
INSERT INTO public.hourly_price VALUES ('2023-03-29 13:00:00+03', 15.4);
INSERT INTO public.hourly_price VALUES ('2023-03-29 14:00:00+03', 13.96);
INSERT INTO public.hourly_price VALUES ('2023-03-29 15:00:00+03', 12.69);
INSERT INTO public.hourly_price VALUES ('2023-03-29 16:00:00+03', 11.85);
INSERT INTO public.hourly_price VALUES ('2023-03-29 17:00:00+03', 11.26);
INSERT INTO public.hourly_price VALUES ('2023-03-29 18:00:00+03', 11.04);
INSERT INTO public.hourly_price VALUES ('2023-03-29 19:00:00+03', 10.67);
INSERT INTO public.hourly_price VALUES ('2023-03-29 20:00:00+03', 11.28);
INSERT INTO public.hourly_price VALUES ('2023-03-29 21:00:00+03', 13.07);
INSERT INTO public.hourly_price VALUES ('2023-03-29 22:00:00+03', 15.5);
INSERT INTO public.hourly_price VALUES ('2023-03-29 23:00:00+03', 16.09);
INSERT INTO public.hourly_price VALUES ('2023-03-30 00:00:00+03', 14.08);
INSERT INTO public.hourly_price VALUES ('2023-03-30 01:00:00+03', 12.24);
INSERT INTO public.hourly_price VALUES ('2023-03-30 02:00:00+03', 11.39);
INSERT INTO public.hourly_price VALUES ('2023-03-30 03:00:00+03', 10.18);
INSERT INTO public.hourly_price VALUES ('2023-03-30 04:00:00+03', 9.87);
INSERT INTO public.hourly_price VALUES ('2023-03-30 05:00:00+03', 9.05);
INSERT INTO public.hourly_price VALUES ('2023-03-30 06:00:00+03', 8.88);
INSERT INTO public.hourly_price VALUES ('2023-03-30 07:00:00+03', 8.66);
INSERT INTO public.hourly_price VALUES ('2023-03-30 08:00:00+03', 8.57);
INSERT INTO public.hourly_price VALUES ('2023-03-30 09:00:00+03', 8.51);
INSERT INTO public.hourly_price VALUES ('2023-03-30 10:00:00+03', 13.75);
INSERT INTO public.hourly_price VALUES ('2023-03-30 11:00:00+03', 14.68);
INSERT INTO public.hourly_price VALUES ('2023-03-30 12:00:00+03', 14.22);
INSERT INTO public.hourly_price VALUES ('2023-03-30 13:00:00+03', 12.1);
INSERT INTO public.hourly_price VALUES ('2023-03-30 14:00:00+03', 9.97);
INSERT INTO public.hourly_price VALUES ('2023-03-30 15:00:00+03', 8.8);
INSERT INTO public.hourly_price VALUES ('2023-03-30 16:00:00+03', 7.55);
INSERT INTO public.hourly_price VALUES ('2023-03-30 17:00:00+03', 5.55);
INSERT INTO public.hourly_price VALUES ('2023-03-30 18:00:00+03', 5.32);
INSERT INTO public.hourly_price VALUES ('2023-03-30 19:00:00+03', 5.45);
INSERT INTO public.hourly_price VALUES ('2023-03-30 20:00:00+03', 5.12);
INSERT INTO public.hourly_price VALUES ('2023-03-30 21:00:00+03', 7.12);
INSERT INTO public.hourly_price VALUES ('2023-03-30 22:00:00+03', 6.21);
INSERT INTO public.hourly_price VALUES ('2023-03-30 23:00:00+03', 5.45);
INSERT INTO public.hourly_price VALUES ('2023-03-31 00:00:00+03', 4.84);
INSERT INTO public.hourly_price VALUES ('2023-03-31 01:00:00+03', 4.63);
INSERT INTO public.hourly_price VALUES ('2023-03-31 02:00:00+03', 4.28);
INSERT INTO public.hourly_price VALUES ('2023-03-31 03:00:00+03', 3.78);
INSERT INTO public.hourly_price VALUES ('2023-03-31 04:00:00+03', 4.1);
INSERT INTO public.hourly_price VALUES ('2023-03-31 05:00:00+03', 4.17);
INSERT INTO public.hourly_price VALUES ('2023-03-31 06:00:00+03', 4.07);
INSERT INTO public.hourly_price VALUES ('2023-03-31 07:00:00+03', 4.14);
INSERT INTO public.hourly_price VALUES ('2023-03-31 08:00:00+03', 4.36);
INSERT INTO public.hourly_price VALUES ('2023-03-31 09:00:00+03', 4.53);
INSERT INTO public.hourly_price VALUES ('2023-03-31 10:00:00+03', 4.8);
INSERT INTO public.hourly_price VALUES ('2023-03-31 11:00:00+03', 6.39);
INSERT INTO public.hourly_price VALUES ('2023-03-31 12:00:00+03', 8.26);
INSERT INTO public.hourly_price VALUES ('2023-03-31 13:00:00+03', 10.69);
INSERT INTO public.hourly_price VALUES ('2023-03-31 14:00:00+03', 13.24);
INSERT INTO public.hourly_price VALUES ('2023-03-31 15:00:00+03', 8.81);
INSERT INTO public.hourly_price VALUES ('2023-03-31 16:00:00+03', 8.16);
INSERT INTO public.hourly_price VALUES ('2023-03-31 17:00:00+03', 6.26);
INSERT INTO public.hourly_price VALUES ('2023-03-31 18:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-03-31 19:00:00+03', 5.24);
INSERT INTO public.hourly_price VALUES ('2023-03-31 20:00:00+03', 5.1);
INSERT INTO public.hourly_price VALUES ('2023-03-31 21:00:00+03', 6.75);
INSERT INTO public.hourly_price VALUES ('2023-03-31 22:00:00+03', 7.82);
INSERT INTO public.hourly_price VALUES ('2023-03-31 23:00:00+03', 7.23);
INSERT INTO public.hourly_price VALUES ('2023-04-01 00:00:00+03', 5.29);
INSERT INTO public.hourly_price VALUES ('2023-04-01 01:00:00+03', 4.5);
INSERT INTO public.hourly_price VALUES ('2023-04-01 02:00:00+03', 3.94);
INSERT INTO public.hourly_price VALUES ('2023-04-01 03:00:00+03', 3.3);
INSERT INTO public.hourly_price VALUES ('2023-04-01 04:00:00+03', 4.35);
INSERT INTO public.hourly_price VALUES ('2023-04-01 05:00:00+03', 4.03);
INSERT INTO public.hourly_price VALUES ('2023-04-01 06:00:00+03', 3.85);
INSERT INTO public.hourly_price VALUES ('2023-04-01 07:00:00+03', 3.91);
INSERT INTO public.hourly_price VALUES ('2023-04-01 08:00:00+03', 3.87);
INSERT INTO public.hourly_price VALUES ('2023-04-01 09:00:00+03', 3.89);
INSERT INTO public.hourly_price VALUES ('2023-04-01 10:00:00+03', 3.78);
INSERT INTO public.hourly_price VALUES ('2023-04-01 11:00:00+03', 4.71);
INSERT INTO public.hourly_price VALUES ('2023-04-01 12:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-04-01 13:00:00+03', 6.49);
INSERT INTO public.hourly_price VALUES ('2023-04-01 14:00:00+03', 5.45);
INSERT INTO public.hourly_price VALUES ('2023-04-01 15:00:00+03', 5.07);
INSERT INTO public.hourly_price VALUES ('2023-04-01 16:00:00+03', 4.51);
INSERT INTO public.hourly_price VALUES ('2023-04-01 17:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-04-01 18:00:00+03', 3.69);
INSERT INTO public.hourly_price VALUES ('2023-04-01 19:00:00+03', 4);
INSERT INTO public.hourly_price VALUES ('2023-04-01 20:00:00+03', 4.46);
INSERT INTO public.hourly_price VALUES ('2023-04-01 21:00:00+03', 5.36);
INSERT INTO public.hourly_price VALUES ('2023-04-01 22:00:00+03', 5.85);
INSERT INTO public.hourly_price VALUES ('2023-04-01 23:00:00+03', 5.85);
INSERT INTO public.hourly_price VALUES ('2023-04-02 00:00:00+03', 5.42);
INSERT INTO public.hourly_price VALUES ('2023-04-02 01:00:00+03', 4.84);
INSERT INTO public.hourly_price VALUES ('2023-04-02 02:00:00+03', 4.36);
INSERT INTO public.hourly_price VALUES ('2023-04-02 03:00:00+03', 3.76);
INSERT INTO public.hourly_price VALUES ('2023-04-02 04:00:00+03', 4.9);
INSERT INTO public.hourly_price VALUES ('2023-04-02 05:00:00+03', 4.8);
INSERT INTO public.hourly_price VALUES ('2023-04-02 06:00:00+03', 4.78);
INSERT INTO public.hourly_price VALUES ('2023-04-02 07:00:00+03', 4.83);
INSERT INTO public.hourly_price VALUES ('2023-04-02 08:00:00+03', 5);
INSERT INTO public.hourly_price VALUES ('2023-04-02 09:00:00+03', 5.38);
INSERT INTO public.hourly_price VALUES ('2023-04-02 10:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-04-02 11:00:00+03', 4.91);
INSERT INTO public.hourly_price VALUES ('2023-04-02 12:00:00+03', 5.51);
INSERT INTO public.hourly_price VALUES ('2023-04-02 13:00:00+03', 6.35);
INSERT INTO public.hourly_price VALUES ('2023-04-02 14:00:00+03', 5.68);
INSERT INTO public.hourly_price VALUES ('2023-04-02 15:00:00+03', 5.39);
INSERT INTO public.hourly_price VALUES ('2023-04-02 16:00:00+03', 4.75);
INSERT INTO public.hourly_price VALUES ('2023-04-02 17:00:00+03', 2.94);
INSERT INTO public.hourly_price VALUES ('2023-04-02 18:00:00+03', 2.71);
INSERT INTO public.hourly_price VALUES ('2023-04-02 19:00:00+03', 2.82);
INSERT INTO public.hourly_price VALUES ('2023-04-02 20:00:00+03', 3.5);
INSERT INTO public.hourly_price VALUES ('2023-04-02 21:00:00+03', 5.23);
INSERT INTO public.hourly_price VALUES ('2023-04-02 22:00:00+03', 10.03);
INSERT INTO public.hourly_price VALUES ('2023-04-02 23:00:00+03', 11.08);
INSERT INTO public.hourly_price VALUES ('2023-04-03 00:00:00+03', 9.35);
INSERT INTO public.hourly_price VALUES ('2023-04-03 01:00:00+03', 8.55);
INSERT INTO public.hourly_price VALUES ('2023-04-03 02:00:00+03', 6.72);
INSERT INTO public.hourly_price VALUES ('2023-04-03 03:00:00+03', 6.04);
INSERT INTO public.hourly_price VALUES ('2023-04-03 04:00:00+03', 7.84);
INSERT INTO public.hourly_price VALUES ('2023-04-03 05:00:00+03', 7.5);
INSERT INTO public.hourly_price VALUES ('2023-04-03 06:00:00+03', 7.71);
INSERT INTO public.hourly_price VALUES ('2023-04-03 07:00:00+03', 7.88);
INSERT INTO public.hourly_price VALUES ('2023-04-03 08:00:00+03', 8.52);
INSERT INTO public.hourly_price VALUES ('2023-04-03 09:00:00+03', 11.55);
INSERT INTO public.hourly_price VALUES ('2023-04-03 10:00:00+03', 14.77);
INSERT INTO public.hourly_price VALUES ('2023-04-03 11:00:00+03', 17.93);
INSERT INTO public.hourly_price VALUES ('2023-04-03 12:00:00+03', 17.46);
INSERT INTO public.hourly_price VALUES ('2023-04-03 13:00:00+03', 12.3);
INSERT INTO public.hourly_price VALUES ('2023-04-03 14:00:00+03', 10.46);
INSERT INTO public.hourly_price VALUES ('2023-04-03 15:00:00+03', 9.53);
INSERT INTO public.hourly_price VALUES ('2023-04-03 16:00:00+03', 8.91);
INSERT INTO public.hourly_price VALUES ('2023-04-03 17:00:00+03', 8.24);
INSERT INTO public.hourly_price VALUES ('2023-04-03 18:00:00+03', 7.88);
INSERT INTO public.hourly_price VALUES ('2023-04-03 19:00:00+03', 8.47);
INSERT INTO public.hourly_price VALUES ('2023-04-03 20:00:00+03', 8.8);
INSERT INTO public.hourly_price VALUES ('2023-04-03 21:00:00+03', 10.77);
INSERT INTO public.hourly_price VALUES ('2023-04-03 22:00:00+03', 11.84);
INSERT INTO public.hourly_price VALUES ('2023-04-03 23:00:00+03', 16.39);
INSERT INTO public.hourly_price VALUES ('2023-04-04 00:00:00+03', 16.65);
INSERT INTO public.hourly_price VALUES ('2023-04-04 01:00:00+03', 14.66);
INSERT INTO public.hourly_price VALUES ('2023-04-04 02:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-04-04 03:00:00+03', 10.46);
INSERT INTO public.hourly_price VALUES ('2023-04-04 04:00:00+03', 9.45);
INSERT INTO public.hourly_price VALUES ('2023-04-04 05:00:00+03', 9.69);
INSERT INTO public.hourly_price VALUES ('2023-04-04 06:00:00+03', 9.9);
INSERT INTO public.hourly_price VALUES ('2023-04-04 07:00:00+03', 9.91);
INSERT INTO public.hourly_price VALUES ('2023-04-04 08:00:00+03', 11.85);
INSERT INTO public.hourly_price VALUES ('2023-04-04 09:00:00+03', 12.1);
INSERT INTO public.hourly_price VALUES ('2023-04-04 10:00:00+03', 12.98);
INSERT INTO public.hourly_price VALUES ('2023-04-04 11:00:00+03', 19.23);
INSERT INTO public.hourly_price VALUES ('2023-04-04 12:00:00+03', 19.03);
INSERT INTO public.hourly_price VALUES ('2023-04-04 13:00:00+03', 14.88);
INSERT INTO public.hourly_price VALUES ('2023-04-04 14:00:00+03', 12.71);
INSERT INTO public.hourly_price VALUES ('2023-04-04 15:00:00+03', 11.99);
INSERT INTO public.hourly_price VALUES ('2023-04-04 16:00:00+03', 11.7);
INSERT INTO public.hourly_price VALUES ('2023-04-04 17:00:00+03', 11.61);
INSERT INTO public.hourly_price VALUES ('2023-04-04 18:00:00+03', 11.52);
INSERT INTO public.hourly_price VALUES ('2023-04-04 19:00:00+03', 11.67);
INSERT INTO public.hourly_price VALUES ('2023-04-04 20:00:00+03', 11.97);
INSERT INTO public.hourly_price VALUES ('2023-04-04 21:00:00+03', 12.77);
INSERT INTO public.hourly_price VALUES ('2023-04-04 22:00:00+03', 13.09);
INSERT INTO public.hourly_price VALUES ('2023-04-04 23:00:00+03', 13.13);
INSERT INTO public.hourly_price VALUES ('2023-04-05 00:00:00+03', 13.97);
INSERT INTO public.hourly_price VALUES ('2023-04-05 01:00:00+03', 13.29);
INSERT INTO public.hourly_price VALUES ('2023-04-05 02:00:00+03', 12.58);
INSERT INTO public.hourly_price VALUES ('2023-04-05 03:00:00+03', 12.08);
INSERT INTO public.hourly_price VALUES ('2023-04-05 04:00:00+03', 11.04);
INSERT INTO public.hourly_price VALUES ('2023-04-05 05:00:00+03', 10.85);
INSERT INTO public.hourly_price VALUES ('2023-04-05 06:00:00+03', 10.71);
INSERT INTO public.hourly_price VALUES ('2023-04-05 07:00:00+03', 10.71);
INSERT INTO public.hourly_price VALUES ('2023-04-05 08:00:00+03', 12.04);
INSERT INTO public.hourly_price VALUES ('2023-04-05 09:00:00+03', 12.46);
INSERT INTO public.hourly_price VALUES ('2023-04-05 10:00:00+03', 13);
INSERT INTO public.hourly_price VALUES ('2023-04-05 11:00:00+03', 16.5);
INSERT INTO public.hourly_price VALUES ('2023-04-05 12:00:00+03', 18.86);
INSERT INTO public.hourly_price VALUES ('2023-04-05 13:00:00+03', 14.57);
INSERT INTO public.hourly_price VALUES ('2023-04-05 14:00:00+03', 12.75);
INSERT INTO public.hourly_price VALUES ('2023-04-05 15:00:00+03', 12.26);
INSERT INTO public.hourly_price VALUES ('2023-04-05 16:00:00+03', 12.11);
INSERT INTO public.hourly_price VALUES ('2023-04-05 17:00:00+03', 12.13);
INSERT INTO public.hourly_price VALUES ('2023-04-05 18:00:00+03', 12.09);
INSERT INTO public.hourly_price VALUES ('2023-04-05 19:00:00+03', 12.09);
INSERT INTO public.hourly_price VALUES ('2023-04-05 20:00:00+03', 12.1);
INSERT INTO public.hourly_price VALUES ('2023-04-05 21:00:00+03', 12.26);
INSERT INTO public.hourly_price VALUES ('2023-04-05 22:00:00+03', 12.27);
INSERT INTO public.hourly_price VALUES ('2023-04-05 23:00:00+03', 12.14);
INSERT INTO public.hourly_price VALUES ('2023-04-06 00:00:00+03', 10.43);
INSERT INTO public.hourly_price VALUES ('2023-04-06 01:00:00+03', 8.85);
INSERT INTO public.hourly_price VALUES ('2023-04-06 02:00:00+03', 7.45);
INSERT INTO public.hourly_price VALUES ('2023-04-06 03:00:00+03', 6.61);
INSERT INTO public.hourly_price VALUES ('2023-04-06 04:00:00+03', 8.26);
INSERT INTO public.hourly_price VALUES ('2023-04-06 05:00:00+03', 8.49);
INSERT INTO public.hourly_price VALUES ('2023-04-06 06:00:00+03', 9.15);
INSERT INTO public.hourly_price VALUES ('2023-04-06 07:00:00+03', 9.39);
INSERT INTO public.hourly_price VALUES ('2023-04-06 08:00:00+03', 9.84);
INSERT INTO public.hourly_price VALUES ('2023-04-06 09:00:00+03', 10.12);
INSERT INTO public.hourly_price VALUES ('2023-04-06 10:00:00+03', 12.63);
INSERT INTO public.hourly_price VALUES ('2023-04-06 11:00:00+03', 12.94);
INSERT INTO public.hourly_price VALUES ('2023-04-06 12:00:00+03', 12.99);
INSERT INTO public.hourly_price VALUES ('2023-04-06 13:00:00+03', 12.9);
INSERT INTO public.hourly_price VALUES ('2023-04-06 14:00:00+03', 12.31);
INSERT INTO public.hourly_price VALUES ('2023-04-06 15:00:00+03', 11.28);
INSERT INTO public.hourly_price VALUES ('2023-04-06 16:00:00+03', 10.66);
INSERT INTO public.hourly_price VALUES ('2023-04-06 17:00:00+03', 10.01);
INSERT INTO public.hourly_price VALUES ('2023-04-06 18:00:00+03', 9.69);
INSERT INTO public.hourly_price VALUES ('2023-04-06 19:00:00+03', 9.85);
INSERT INTO public.hourly_price VALUES ('2023-04-06 20:00:00+03', 10.18);
INSERT INTO public.hourly_price VALUES ('2023-04-06 21:00:00+03', 10.7);
INSERT INTO public.hourly_price VALUES ('2023-04-06 22:00:00+03', 10.65);
INSERT INTO public.hourly_price VALUES ('2023-04-06 23:00:00+03', 9.83);
INSERT INTO public.hourly_price VALUES ('2023-04-07 00:00:00+03', 9.61);
INSERT INTO public.hourly_price VALUES ('2023-04-07 01:00:00+03', 9.12);
INSERT INTO public.hourly_price VALUES ('2023-04-07 02:00:00+03', 7.71);
INSERT INTO public.hourly_price VALUES ('2023-04-07 03:00:00+03', 6.21);
INSERT INTO public.hourly_price VALUES ('2023-04-07 04:00:00+03', 6.55);
INSERT INTO public.hourly_price VALUES ('2023-04-07 05:00:00+03', 6.6);
INSERT INTO public.hourly_price VALUES ('2023-04-07 06:00:00+03', 6.89);
INSERT INTO public.hourly_price VALUES ('2023-04-07 07:00:00+03', 7.24);
INSERT INTO public.hourly_price VALUES ('2023-04-07 08:00:00+03', 7.62);
INSERT INTO public.hourly_price VALUES ('2023-04-07 09:00:00+03', 7.15);
INSERT INTO public.hourly_price VALUES ('2023-04-07 10:00:00+03', 5.58);
INSERT INTO public.hourly_price VALUES ('2023-04-07 11:00:00+03', 5.41);
INSERT INTO public.hourly_price VALUES ('2023-04-07 12:00:00+03', 5.7);
INSERT INTO public.hourly_price VALUES ('2023-04-07 13:00:00+03', 6.6);
INSERT INTO public.hourly_price VALUES ('2023-04-07 14:00:00+03', 6.67);
INSERT INTO public.hourly_price VALUES ('2023-04-07 15:00:00+03', 6.23);
INSERT INTO public.hourly_price VALUES ('2023-04-07 16:00:00+03', 5.82);
INSERT INTO public.hourly_price VALUES ('2023-04-07 17:00:00+03', 5.29);
INSERT INTO public.hourly_price VALUES ('2023-04-07 18:00:00+03', 5.19);
INSERT INTO public.hourly_price VALUES ('2023-04-07 19:00:00+03', 5.21);
INSERT INTO public.hourly_price VALUES ('2023-04-07 20:00:00+03', 5.37);
INSERT INTO public.hourly_price VALUES ('2023-04-07 21:00:00+03', 6.15);
INSERT INTO public.hourly_price VALUES ('2023-04-07 22:00:00+03', 6.8);
INSERT INTO public.hourly_price VALUES ('2023-04-07 23:00:00+03', 6.77);
INSERT INTO public.hourly_price VALUES ('2023-04-08 00:00:00+03', 6.51);
INSERT INTO public.hourly_price VALUES ('2023-04-08 01:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-04-08 02:00:00+03', 5.63);
INSERT INTO public.hourly_price VALUES ('2023-04-08 03:00:00+03', 5.98);
INSERT INTO public.hourly_price VALUES ('2023-04-08 04:00:00+03', 4.72);
INSERT INTO public.hourly_price VALUES ('2023-04-08 05:00:00+03', 4.8);
INSERT INTO public.hourly_price VALUES ('2023-04-08 06:00:00+03', 4.86);
INSERT INTO public.hourly_price VALUES ('2023-04-08 07:00:00+03', 4.99);
INSERT INTO public.hourly_price VALUES ('2023-04-08 08:00:00+03', 5.11);
INSERT INTO public.hourly_price VALUES ('2023-04-08 09:00:00+03', 5.26);
INSERT INTO public.hourly_price VALUES ('2023-04-08 10:00:00+03', 5.21);
INSERT INTO public.hourly_price VALUES ('2023-04-08 11:00:00+03', 5.28);
INSERT INTO public.hourly_price VALUES ('2023-04-08 12:00:00+03', 5.61);
INSERT INTO public.hourly_price VALUES ('2023-04-08 13:00:00+03', 5.9);
INSERT INTO public.hourly_price VALUES ('2023-04-08 14:00:00+03', 6.19);
INSERT INTO public.hourly_price VALUES ('2023-04-08 15:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-04-08 16:00:00+03', 5.51);
INSERT INTO public.hourly_price VALUES ('2023-04-08 17:00:00+03', 5.38);
INSERT INTO public.hourly_price VALUES ('2023-04-08 18:00:00+03', 5.28);
INSERT INTO public.hourly_price VALUES ('2023-04-08 19:00:00+03', 5.69);
INSERT INTO public.hourly_price VALUES ('2023-04-08 20:00:00+03', 6.51);
INSERT INTO public.hourly_price VALUES ('2023-04-08 21:00:00+03', 7.26);
INSERT INTO public.hourly_price VALUES ('2023-04-08 22:00:00+03', 7.76);
INSERT INTO public.hourly_price VALUES ('2023-04-08 23:00:00+03', 7.95);
INSERT INTO public.hourly_price VALUES ('2023-04-09 00:00:00+03', 7.46);
INSERT INTO public.hourly_price VALUES ('2023-04-09 01:00:00+03', 7.38);
INSERT INTO public.hourly_price VALUES ('2023-04-09 02:00:00+03', 6.41);
INSERT INTO public.hourly_price VALUES ('2023-04-09 03:00:00+03', 5.49);
INSERT INTO public.hourly_price VALUES ('2023-04-09 04:00:00+03', 5.75);
INSERT INTO public.hourly_price VALUES ('2023-04-09 05:00:00+03', 5.82);
INSERT INTO public.hourly_price VALUES ('2023-04-09 06:00:00+03', 5.78);
INSERT INTO public.hourly_price VALUES ('2023-04-09 07:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-04-09 08:00:00+03', 6.03);
INSERT INTO public.hourly_price VALUES ('2023-04-09 09:00:00+03', 5.89);
INSERT INTO public.hourly_price VALUES ('2023-04-09 10:00:00+03', 5.74);
INSERT INTO public.hourly_price VALUES ('2023-04-09 11:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-04-09 12:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-04-09 13:00:00+03', 5.82);
INSERT INTO public.hourly_price VALUES ('2023-04-09 14:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-04-09 15:00:00+03', 5.48);
INSERT INTO public.hourly_price VALUES ('2023-04-09 16:00:00+03', 5.27);
INSERT INTO public.hourly_price VALUES ('2023-04-09 17:00:00+03', 5.41);
INSERT INTO public.hourly_price VALUES ('2023-04-09 18:00:00+03', 5.31);
INSERT INTO public.hourly_price VALUES ('2023-04-09 19:00:00+03', 5.37);
INSERT INTO public.hourly_price VALUES ('2023-04-09 20:00:00+03', 5.42);
INSERT INTO public.hourly_price VALUES ('2023-04-09 21:00:00+03', 5.76);
INSERT INTO public.hourly_price VALUES ('2023-04-09 22:00:00+03', 6.27);
INSERT INTO public.hourly_price VALUES ('2023-04-09 23:00:00+03', 6.58);
INSERT INTO public.hourly_price VALUES ('2023-04-10 00:00:00+03', 6.24);
INSERT INTO public.hourly_price VALUES ('2023-04-10 01:00:00+03', 5.78);
INSERT INTO public.hourly_price VALUES ('2023-04-10 02:00:00+03', 5.49);
INSERT INTO public.hourly_price VALUES ('2023-04-10 03:00:00+03', 5.07);
INSERT INTO public.hourly_price VALUES ('2023-04-10 04:00:00+03', 4.15);
INSERT INTO public.hourly_price VALUES ('2023-04-10 05:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-04-10 06:00:00+03', 4.24);
INSERT INTO public.hourly_price VALUES ('2023-04-10 07:00:00+03', 4.4);
INSERT INTO public.hourly_price VALUES ('2023-04-10 08:00:00+03', 4.58);
INSERT INTO public.hourly_price VALUES ('2023-04-10 09:00:00+03', 5.02);
INSERT INTO public.hourly_price VALUES ('2023-04-10 10:00:00+03', 5.36);
INSERT INTO public.hourly_price VALUES ('2023-04-10 11:00:00+03', 5.32);
INSERT INTO public.hourly_price VALUES ('2023-04-10 12:00:00+03', 5.49);
INSERT INTO public.hourly_price VALUES ('2023-04-10 13:00:00+03', 5.29);
INSERT INTO public.hourly_price VALUES ('2023-04-10 14:00:00+03', 3.02);
INSERT INTO public.hourly_price VALUES ('2023-04-10 15:00:00+03', 1.49);
INSERT INTO public.hourly_price VALUES ('2023-04-10 16:00:00+03', 1.45);
INSERT INTO public.hourly_price VALUES ('2023-04-10 17:00:00+03', 1.1);
INSERT INTO public.hourly_price VALUES ('2023-04-10 18:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-04-10 19:00:00+03', 0.24);
INSERT INTO public.hourly_price VALUES ('2023-04-10 20:00:00+03', 0.46);
INSERT INTO public.hourly_price VALUES ('2023-04-10 21:00:00+03', 2.81);
INSERT INTO public.hourly_price VALUES ('2023-04-10 22:00:00+03', 4.24);
INSERT INTO public.hourly_price VALUES ('2023-04-10 23:00:00+03', 4.92);
INSERT INTO public.hourly_price VALUES ('2023-04-11 00:00:00+03', 3.97);
INSERT INTO public.hourly_price VALUES ('2023-04-11 01:00:00+03', 2.88);
INSERT INTO public.hourly_price VALUES ('2023-04-11 02:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-04-11 03:00:00+03', 0.33);
INSERT INTO public.hourly_price VALUES ('2023-04-11 04:00:00+03', 0.16);
INSERT INTO public.hourly_price VALUES ('2023-04-11 05:00:00+03', 0.11);
INSERT INTO public.hourly_price VALUES ('2023-04-11 06:00:00+03', 0.08);
INSERT INTO public.hourly_price VALUES ('2023-04-11 07:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-04-11 08:00:00+03', 0.69);
INSERT INTO public.hourly_price VALUES ('2023-04-11 09:00:00+03', 3.65);
INSERT INTO public.hourly_price VALUES ('2023-04-11 10:00:00+03', 4.3);
INSERT INTO public.hourly_price VALUES ('2023-04-11 11:00:00+03', 5.13);
INSERT INTO public.hourly_price VALUES ('2023-04-11 12:00:00+03', 5.96);
INSERT INTO public.hourly_price VALUES ('2023-04-11 13:00:00+03', 5.8);
INSERT INTO public.hourly_price VALUES ('2023-04-11 14:00:00+03', 4.4);
INSERT INTO public.hourly_price VALUES ('2023-04-11 15:00:00+03', 3.48);
INSERT INTO public.hourly_price VALUES ('2023-04-11 16:00:00+03', 3.4);
INSERT INTO public.hourly_price VALUES ('2023-04-11 17:00:00+03', 3.18);
INSERT INTO public.hourly_price VALUES ('2023-04-11 18:00:00+03', 2.82);
INSERT INTO public.hourly_price VALUES ('2023-04-11 19:00:00+03', 3.02);
INSERT INTO public.hourly_price VALUES ('2023-04-11 20:00:00+03', 3.89);
INSERT INTO public.hourly_price VALUES ('2023-04-11 21:00:00+03', 5.28);
INSERT INTO public.hourly_price VALUES ('2023-04-11 22:00:00+03', 4.93);
INSERT INTO public.hourly_price VALUES ('2023-04-11 23:00:00+03', 4.46);
INSERT INTO public.hourly_price VALUES ('2023-04-12 00:00:00+03', 4.33);
INSERT INTO public.hourly_price VALUES ('2023-04-12 01:00:00+03', 4.18);
INSERT INTO public.hourly_price VALUES ('2023-04-12 02:00:00+03', 3.86);
INSERT INTO public.hourly_price VALUES ('2023-04-12 03:00:00+03', 3.51);
INSERT INTO public.hourly_price VALUES ('2023-04-12 04:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-04-12 05:00:00+03', 3.85);
INSERT INTO public.hourly_price VALUES ('2023-04-12 06:00:00+03', 4.01);
INSERT INTO public.hourly_price VALUES ('2023-04-12 07:00:00+03', 4.24);
INSERT INTO public.hourly_price VALUES ('2023-04-12 08:00:00+03', 4.33);
INSERT INTO public.hourly_price VALUES ('2023-04-12 09:00:00+03', 5.1);
INSERT INTO public.hourly_price VALUES ('2023-04-12 10:00:00+03', 5.3);
INSERT INTO public.hourly_price VALUES ('2023-04-12 11:00:00+03', 6.35);
INSERT INTO public.hourly_price VALUES ('2023-04-12 12:00:00+03', 6.54);
INSERT INTO public.hourly_price VALUES ('2023-04-12 13:00:00+03', 6.01);
INSERT INTO public.hourly_price VALUES ('2023-04-12 14:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-04-12 15:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-04-12 16:00:00+03', 5.53);
INSERT INTO public.hourly_price VALUES ('2023-04-12 17:00:00+03', 5.11);
INSERT INTO public.hourly_price VALUES ('2023-04-12 18:00:00+03', 4.3);
INSERT INTO public.hourly_price VALUES ('2023-04-12 19:00:00+03', 3.84);
INSERT INTO public.hourly_price VALUES ('2023-04-12 20:00:00+03', 3.54);
INSERT INTO public.hourly_price VALUES ('2023-04-12 21:00:00+03', 3.87);
INSERT INTO public.hourly_price VALUES ('2023-04-12 22:00:00+03', 4.08);
INSERT INTO public.hourly_price VALUES ('2023-04-12 23:00:00+03', 3.58);
INSERT INTO public.hourly_price VALUES ('2023-04-13 00:00:00+03', 2.99);
INSERT INTO public.hourly_price VALUES ('2023-04-13 01:00:00+03', 2.78);
INSERT INTO public.hourly_price VALUES ('2023-04-13 02:00:00+03', 2.18);
INSERT INTO public.hourly_price VALUES ('2023-04-13 03:00:00+03', 0.77);
INSERT INTO public.hourly_price VALUES ('2023-04-13 04:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-04-13 05:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-04-13 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-04-13 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-04-13 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-04-13 09:00:00+03', 0.44);
INSERT INTO public.hourly_price VALUES ('2023-04-13 10:00:00+03', 2.78);
INSERT INTO public.hourly_price VALUES ('2023-04-13 11:00:00+03', 3.05);
INSERT INTO public.hourly_price VALUES ('2023-04-13 12:00:00+03', 3.21);
INSERT INTO public.hourly_price VALUES ('2023-04-13 13:00:00+03', 3.09);
INSERT INTO public.hourly_price VALUES ('2023-04-13 14:00:00+03', 3.01);
INSERT INTO public.hourly_price VALUES ('2023-04-13 15:00:00+03', 2.86);
INSERT INTO public.hourly_price VALUES ('2023-04-13 16:00:00+03', 2.71);
INSERT INTO public.hourly_price VALUES ('2023-04-13 17:00:00+03', 2.69);
INSERT INTO public.hourly_price VALUES ('2023-04-13 18:00:00+03', 2.3);
INSERT INTO public.hourly_price VALUES ('2023-04-13 19:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-04-13 20:00:00+03', 2.59);
INSERT INTO public.hourly_price VALUES ('2023-04-13 21:00:00+03', 2.76);
INSERT INTO public.hourly_price VALUES ('2023-04-13 22:00:00+03', 2.76);
INSERT INTO public.hourly_price VALUES ('2023-04-13 23:00:00+03', 2.77);
INSERT INTO public.hourly_price VALUES ('2023-04-14 00:00:00+03', 2.62);
INSERT INTO public.hourly_price VALUES ('2023-04-14 01:00:00+03', 2.26);
INSERT INTO public.hourly_price VALUES ('2023-04-14 02:00:00+03', 1.83);
INSERT INTO public.hourly_price VALUES ('2023-04-14 03:00:00+03', 1.2);
INSERT INTO public.hourly_price VALUES ('2023-04-14 04:00:00+03', 0.45);
INSERT INTO public.hourly_price VALUES ('2023-04-14 05:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-04-14 06:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-04-14 07:00:00+03', 2.59);
INSERT INTO public.hourly_price VALUES ('2023-04-14 08:00:00+03', 2.91);
INSERT INTO public.hourly_price VALUES ('2023-04-14 09:00:00+03', 3.03);
INSERT INTO public.hourly_price VALUES ('2023-04-14 10:00:00+03', 3.76);
INSERT INTO public.hourly_price VALUES ('2023-04-14 11:00:00+03', 4.85);
INSERT INTO public.hourly_price VALUES ('2023-04-14 12:00:00+03', 5.42);
INSERT INTO public.hourly_price VALUES ('2023-04-14 13:00:00+03', 5.37);
INSERT INTO public.hourly_price VALUES ('2023-04-14 14:00:00+03', 4.87);
INSERT INTO public.hourly_price VALUES ('2023-04-14 15:00:00+03', 4.34);
INSERT INTO public.hourly_price VALUES ('2023-04-14 16:00:00+03', 4.05);
INSERT INTO public.hourly_price VALUES ('2023-04-14 17:00:00+03', 3.87);
INSERT INTO public.hourly_price VALUES ('2023-04-14 18:00:00+03', 3.69);
INSERT INTO public.hourly_price VALUES ('2023-04-14 19:00:00+03', 3.7);
INSERT INTO public.hourly_price VALUES ('2023-04-14 20:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-04-14 21:00:00+03', 3.93);
INSERT INTO public.hourly_price VALUES ('2023-04-14 22:00:00+03', 4);
INSERT INTO public.hourly_price VALUES ('2023-04-14 23:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-04-15 00:00:00+03', 3.5);
INSERT INTO public.hourly_price VALUES ('2023-04-15 01:00:00+03', 3.24);
INSERT INTO public.hourly_price VALUES ('2023-04-15 02:00:00+03', 3.12);
INSERT INTO public.hourly_price VALUES ('2023-04-15 03:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-04-15 04:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-04-15 05:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-04-15 06:00:00+03', 3.14);
INSERT INTO public.hourly_price VALUES ('2023-04-15 07:00:00+03', 3.29);
INSERT INTO public.hourly_price VALUES ('2023-04-15 08:00:00+03', 3.56);
INSERT INTO public.hourly_price VALUES ('2023-04-15 09:00:00+03', 4.18);
INSERT INTO public.hourly_price VALUES ('2023-04-15 10:00:00+03', 4.3);
INSERT INTO public.hourly_price VALUES ('2023-04-15 11:00:00+03', 4.53);
INSERT INTO public.hourly_price VALUES ('2023-04-15 12:00:00+03', 5.51);
INSERT INTO public.hourly_price VALUES ('2023-04-15 13:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-04-15 14:00:00+03', 4.83);
INSERT INTO public.hourly_price VALUES ('2023-04-15 15:00:00+03', 4.55);
INSERT INTO public.hourly_price VALUES ('2023-04-15 16:00:00+03', 4.46);
INSERT INTO public.hourly_price VALUES ('2023-04-15 17:00:00+03', 4.4);
INSERT INTO public.hourly_price VALUES ('2023-04-15 18:00:00+03', 4.41);
INSERT INTO public.hourly_price VALUES ('2023-04-15 19:00:00+03', 4.47);
INSERT INTO public.hourly_price VALUES ('2023-04-15 20:00:00+03', 4.53);
INSERT INTO public.hourly_price VALUES ('2023-04-15 21:00:00+03', 5.04);
INSERT INTO public.hourly_price VALUES ('2023-04-15 22:00:00+03', 5.7);
INSERT INTO public.hourly_price VALUES ('2023-04-15 23:00:00+03', 6);
INSERT INTO public.hourly_price VALUES ('2023-04-16 00:00:00+03', 5.75);
INSERT INTO public.hourly_price VALUES ('2023-04-16 01:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-04-16 02:00:00+03', 5.16);
INSERT INTO public.hourly_price VALUES ('2023-04-16 03:00:00+03', 4.8);
INSERT INTO public.hourly_price VALUES ('2023-04-16 04:00:00+03', 6.07);
INSERT INTO public.hourly_price VALUES ('2023-04-16 05:00:00+03', 6.11);
INSERT INTO public.hourly_price VALUES ('2023-04-16 06:00:00+03', 6.49);
INSERT INTO public.hourly_price VALUES ('2023-04-16 07:00:00+03', 6.88);
INSERT INTO public.hourly_price VALUES ('2023-04-16 08:00:00+03', 7.2);
INSERT INTO public.hourly_price VALUES ('2023-04-16 09:00:00+03', 7.25);
INSERT INTO public.hourly_price VALUES ('2023-04-16 10:00:00+03', 7.33);
INSERT INTO public.hourly_price VALUES ('2023-04-16 11:00:00+03', 7.42);
INSERT INTO public.hourly_price VALUES ('2023-04-16 12:00:00+03', 7.7);
INSERT INTO public.hourly_price VALUES ('2023-04-16 13:00:00+03', 7.79);
INSERT INTO public.hourly_price VALUES ('2023-04-16 14:00:00+03', 7.74);
INSERT INTO public.hourly_price VALUES ('2023-04-16 15:00:00+03', 7.56);
INSERT INTO public.hourly_price VALUES ('2023-04-16 16:00:00+03', 7.21);
INSERT INTO public.hourly_price VALUES ('2023-04-16 17:00:00+03', 6.93);
INSERT INTO public.hourly_price VALUES ('2023-04-16 18:00:00+03', 6.76);
INSERT INTO public.hourly_price VALUES ('2023-04-16 19:00:00+03', 6.9);
INSERT INTO public.hourly_price VALUES ('2023-04-16 20:00:00+03', 7.52);
INSERT INTO public.hourly_price VALUES ('2023-04-16 21:00:00+03', 8.44);
INSERT INTO public.hourly_price VALUES ('2023-04-16 22:00:00+03', 9.63);
INSERT INTO public.hourly_price VALUES ('2023-04-16 23:00:00+03', 11.41);
INSERT INTO public.hourly_price VALUES ('2023-04-17 00:00:00+03', 11.54);
INSERT INTO public.hourly_price VALUES ('2023-04-17 01:00:00+03', 11.56);
INSERT INTO public.hourly_price VALUES ('2023-04-17 02:00:00+03', 10.17);
INSERT INTO public.hourly_price VALUES ('2023-04-17 03:00:00+03', 7.39);
INSERT INTO public.hourly_price VALUES ('2023-04-17 04:00:00+03', 8.04);
INSERT INTO public.hourly_price VALUES ('2023-04-17 05:00:00+03', 7.93);
INSERT INTO public.hourly_price VALUES ('2023-04-17 06:00:00+03', 7.7);
INSERT INTO public.hourly_price VALUES ('2023-04-17 07:00:00+03', 7.59);
INSERT INTO public.hourly_price VALUES ('2023-04-17 08:00:00+03', 8.25);
INSERT INTO public.hourly_price VALUES ('2023-04-17 09:00:00+03', 11.59);
INSERT INTO public.hourly_price VALUES ('2023-04-17 10:00:00+03', 15.12);
INSERT INTO public.hourly_price VALUES ('2023-04-17 11:00:00+03', 18.98);
INSERT INTO public.hourly_price VALUES ('2023-04-17 12:00:00+03', 19.03);
INSERT INTO public.hourly_price VALUES ('2023-04-17 13:00:00+03', 15.26);
INSERT INTO public.hourly_price VALUES ('2023-04-17 14:00:00+03', 14.15);
INSERT INTO public.hourly_price VALUES ('2023-04-17 15:00:00+03', 11.66);
INSERT INTO public.hourly_price VALUES ('2023-04-17 16:00:00+03', 11.32);
INSERT INTO public.hourly_price VALUES ('2023-04-17 17:00:00+03', 10.98);
INSERT INTO public.hourly_price VALUES ('2023-04-17 18:00:00+03', 10.43);
INSERT INTO public.hourly_price VALUES ('2023-04-17 19:00:00+03', 10.2);
INSERT INTO public.hourly_price VALUES ('2023-04-17 20:00:00+03', 10.35);
INSERT INTO public.hourly_price VALUES ('2023-04-17 21:00:00+03', 10.84);
INSERT INTO public.hourly_price VALUES ('2023-04-17 22:00:00+03', 11.31);
INSERT INTO public.hourly_price VALUES ('2023-04-17 23:00:00+03', 11.32);
INSERT INTO public.hourly_price VALUES ('2023-04-18 00:00:00+03', 10.73);
INSERT INTO public.hourly_price VALUES ('2023-04-18 01:00:00+03', 9.03);
INSERT INTO public.hourly_price VALUES ('2023-04-18 02:00:00+03', 7.7);
INSERT INTO public.hourly_price VALUES ('2023-04-18 03:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-04-18 04:00:00+03', 6.93);
INSERT INTO public.hourly_price VALUES ('2023-04-18 05:00:00+03', 6.99);
INSERT INTO public.hourly_price VALUES ('2023-04-18 06:00:00+03', 7.16);
INSERT INTO public.hourly_price VALUES ('2023-04-18 07:00:00+03', 7.69);
INSERT INTO public.hourly_price VALUES ('2023-04-18 08:00:00+03', 8.46);
INSERT INTO public.hourly_price VALUES ('2023-04-18 09:00:00+03', 9.35);
INSERT INTO public.hourly_price VALUES ('2023-04-18 10:00:00+03', 11.56);
INSERT INTO public.hourly_price VALUES ('2023-04-18 11:00:00+03', 14.94);
INSERT INTO public.hourly_price VALUES ('2023-04-18 12:00:00+03', 16.51);
INSERT INTO public.hourly_price VALUES ('2023-04-18 13:00:00+03', 13.27);
INSERT INTO public.hourly_price VALUES ('2023-04-18 14:00:00+03', 11.32);
INSERT INTO public.hourly_price VALUES ('2023-04-18 15:00:00+03', 9.96);
INSERT INTO public.hourly_price VALUES ('2023-04-18 16:00:00+03', 9.24);
INSERT INTO public.hourly_price VALUES ('2023-04-18 17:00:00+03', 8.41);
INSERT INTO public.hourly_price VALUES ('2023-04-18 18:00:00+03', 7.69);
INSERT INTO public.hourly_price VALUES ('2023-04-18 19:00:00+03', 7.31);
INSERT INTO public.hourly_price VALUES ('2023-04-18 20:00:00+03', 7.51);
INSERT INTO public.hourly_price VALUES ('2023-04-18 21:00:00+03', 8.71);
INSERT INTO public.hourly_price VALUES ('2023-04-18 22:00:00+03', 9.34);
INSERT INTO public.hourly_price VALUES ('2023-04-18 23:00:00+03', 9.27);
INSERT INTO public.hourly_price VALUES ('2023-04-19 00:00:00+03', 10.1);
INSERT INTO public.hourly_price VALUES ('2023-04-19 01:00:00+03', 9.31);
INSERT INTO public.hourly_price VALUES ('2023-04-19 02:00:00+03', 7.66);
INSERT INTO public.hourly_price VALUES ('2023-04-19 03:00:00+03', 6.23);
INSERT INTO public.hourly_price VALUES ('2023-04-19 04:00:00+03', 6.67);
INSERT INTO public.hourly_price VALUES ('2023-04-19 05:00:00+03', 6.61);
INSERT INTO public.hourly_price VALUES ('2023-04-19 06:00:00+03', 6.3);
INSERT INTO public.hourly_price VALUES ('2023-04-19 07:00:00+03', 6.32);
INSERT INTO public.hourly_price VALUES ('2023-04-19 08:00:00+03', 6.43);
INSERT INTO public.hourly_price VALUES ('2023-04-19 09:00:00+03', 6.71);
INSERT INTO public.hourly_price VALUES ('2023-04-19 10:00:00+03', 8.73);
INSERT INTO public.hourly_price VALUES ('2023-04-19 11:00:00+03', 11);
INSERT INTO public.hourly_price VALUES ('2023-04-19 12:00:00+03', 9.01);
INSERT INTO public.hourly_price VALUES ('2023-04-19 13:00:00+03', 8.24);
INSERT INTO public.hourly_price VALUES ('2023-04-19 14:00:00+03', 7.23);
INSERT INTO public.hourly_price VALUES ('2023-04-19 15:00:00+03', 6.33);
INSERT INTO public.hourly_price VALUES ('2023-04-19 16:00:00+03', 4.26);
INSERT INTO public.hourly_price VALUES ('2023-04-19 17:00:00+03', 3.75);
INSERT INTO public.hourly_price VALUES ('2023-04-19 18:00:00+03', 3.75);
INSERT INTO public.hourly_price VALUES ('2023-04-19 19:00:00+03', 3.64);
INSERT INTO public.hourly_price VALUES ('2023-04-19 20:00:00+03', 3.9);
INSERT INTO public.hourly_price VALUES ('2023-04-19 21:00:00+03', 6.26);
INSERT INTO public.hourly_price VALUES ('2023-04-19 22:00:00+03', 6.71);
INSERT INTO public.hourly_price VALUES ('2023-04-19 23:00:00+03', 6.71);
INSERT INTO public.hourly_price VALUES ('2023-04-20 00:00:00+03', 6.59);
INSERT INTO public.hourly_price VALUES ('2023-04-20 01:00:00+03', 5.6);
INSERT INTO public.hourly_price VALUES ('2023-04-20 02:00:00+03', 4.59);
INSERT INTO public.hourly_price VALUES ('2023-04-20 03:00:00+03', 3.94);
INSERT INTO public.hourly_price VALUES ('2023-04-20 04:00:00+03', 4.34);
INSERT INTO public.hourly_price VALUES ('2023-04-20 05:00:00+03', 4.06);
INSERT INTO public.hourly_price VALUES ('2023-04-20 06:00:00+03', 3.98);
INSERT INTO public.hourly_price VALUES ('2023-04-20 07:00:00+03', 4.02);
INSERT INTO public.hourly_price VALUES ('2023-04-20 08:00:00+03', 4.39);
INSERT INTO public.hourly_price VALUES ('2023-04-20 09:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-04-20 10:00:00+03', 6.25);
INSERT INTO public.hourly_price VALUES ('2023-04-20 11:00:00+03', 7.48);
INSERT INTO public.hourly_price VALUES ('2023-04-20 12:00:00+03', 8.56);
INSERT INTO public.hourly_price VALUES ('2023-04-20 13:00:00+03', 8.15);
INSERT INTO public.hourly_price VALUES ('2023-04-20 14:00:00+03', 10.61);
INSERT INTO public.hourly_price VALUES ('2023-04-20 15:00:00+03', 8.75);
INSERT INTO public.hourly_price VALUES ('2023-04-20 16:00:00+03', 10.36);
INSERT INTO public.hourly_price VALUES ('2023-04-20 17:00:00+03', 7.7);
INSERT INTO public.hourly_price VALUES ('2023-04-20 18:00:00+03', 7.04);
INSERT INTO public.hourly_price VALUES ('2023-04-20 19:00:00+03', 6.59);
INSERT INTO public.hourly_price VALUES ('2023-04-20 20:00:00+03', 6.47);
INSERT INTO public.hourly_price VALUES ('2023-04-20 21:00:00+03', 6.48);
INSERT INTO public.hourly_price VALUES ('2023-04-20 22:00:00+03', 7.45);
INSERT INTO public.hourly_price VALUES ('2023-04-20 23:00:00+03', 6.59);
INSERT INTO public.hourly_price VALUES ('2023-04-21 00:00:00+03', 6.19);
INSERT INTO public.hourly_price VALUES ('2023-04-21 01:00:00+03', 5.74);
INSERT INTO public.hourly_price VALUES ('2023-04-21 02:00:00+03', 4.48);
INSERT INTO public.hourly_price VALUES ('2023-04-21 03:00:00+03', 3.59);
INSERT INTO public.hourly_price VALUES ('2023-04-21 04:00:00+03', 3.85);
INSERT INTO public.hourly_price VALUES ('2023-04-21 05:00:00+03', 4.29);
INSERT INTO public.hourly_price VALUES ('2023-04-21 06:00:00+03', 4.51);
INSERT INTO public.hourly_price VALUES ('2023-04-21 07:00:00+03', 4.88);
INSERT INTO public.hourly_price VALUES ('2023-04-21 08:00:00+03', 5.58);
INSERT INTO public.hourly_price VALUES ('2023-04-21 09:00:00+03', 6.01);
INSERT INTO public.hourly_price VALUES ('2023-04-21 10:00:00+03', 9.62);
INSERT INTO public.hourly_price VALUES ('2023-04-21 11:00:00+03', 12.41);
INSERT INTO public.hourly_price VALUES ('2023-04-21 12:00:00+03', 12.98);
INSERT INTO public.hourly_price VALUES ('2023-04-21 13:00:00+03', 11.41);
INSERT INTO public.hourly_price VALUES ('2023-04-21 14:00:00+03', 9.66);
INSERT INTO public.hourly_price VALUES ('2023-04-21 15:00:00+03', 7.66);
INSERT INTO public.hourly_price VALUES ('2023-04-21 16:00:00+03', 4.58);
INSERT INTO public.hourly_price VALUES ('2023-04-21 17:00:00+03', 3.69);
INSERT INTO public.hourly_price VALUES ('2023-04-21 18:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-04-21 19:00:00+03', 4.11);
INSERT INTO public.hourly_price VALUES ('2023-04-21 20:00:00+03', 5.92);
INSERT INTO public.hourly_price VALUES ('2023-04-21 21:00:00+03', 7.37);
INSERT INTO public.hourly_price VALUES ('2023-04-21 22:00:00+03', 6.76);
INSERT INTO public.hourly_price VALUES ('2023-04-21 23:00:00+03', 6.57);
INSERT INTO public.hourly_price VALUES ('2023-04-22 00:00:00+03', 6.16);
INSERT INTO public.hourly_price VALUES ('2023-04-22 01:00:00+03', 5.62);
INSERT INTO public.hourly_price VALUES ('2023-04-22 02:00:00+03', 4.63);
INSERT INTO public.hourly_price VALUES ('2023-04-22 03:00:00+03', 3.96);
INSERT INTO public.hourly_price VALUES ('2023-04-22 04:00:00+03', 2.94);
INSERT INTO public.hourly_price VALUES ('2023-04-22 05:00:00+03', 2.91);
INSERT INTO public.hourly_price VALUES ('2023-04-22 06:00:00+03', 2.9);
INSERT INTO public.hourly_price VALUES ('2023-04-22 07:00:00+03', 3.02);
INSERT INTO public.hourly_price VALUES ('2023-04-22 08:00:00+03', 3.44);
INSERT INTO public.hourly_price VALUES ('2023-04-22 09:00:00+03', 3.87);
INSERT INTO public.hourly_price VALUES ('2023-04-22 10:00:00+03', 4.4);
INSERT INTO public.hourly_price VALUES ('2023-04-22 11:00:00+03', 4.83);
INSERT INTO public.hourly_price VALUES ('2023-04-22 12:00:00+03', 5.55);
INSERT INTO public.hourly_price VALUES ('2023-04-22 13:00:00+03', 4.9);
INSERT INTO public.hourly_price VALUES ('2023-04-22 14:00:00+03', 4.68);
INSERT INTO public.hourly_price VALUES ('2023-04-22 15:00:00+03', 4.13);
INSERT INTO public.hourly_price VALUES ('2023-04-22 16:00:00+03', 2.88);
INSERT INTO public.hourly_price VALUES ('2023-04-22 17:00:00+03', 1.1);
INSERT INTO public.hourly_price VALUES ('2023-04-22 18:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-04-22 19:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-04-22 20:00:00+03', 4.22);
INSERT INTO public.hourly_price VALUES ('2023-04-22 21:00:00+03', 4.78);
INSERT INTO public.hourly_price VALUES ('2023-04-22 22:00:00+03', 4.92);
INSERT INTO public.hourly_price VALUES ('2023-04-22 23:00:00+03', 4.8);
INSERT INTO public.hourly_price VALUES ('2023-04-23 00:00:00+03', 5.59);
INSERT INTO public.hourly_price VALUES ('2023-04-23 01:00:00+03', 5.15);
INSERT INTO public.hourly_price VALUES ('2023-04-23 02:00:00+03', 4.75);
INSERT INTO public.hourly_price VALUES ('2023-04-23 03:00:00+03', 4.15);
INSERT INTO public.hourly_price VALUES ('2023-04-23 04:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-04-23 05:00:00+03', 4);
INSERT INTO public.hourly_price VALUES ('2023-04-23 06:00:00+03', 4.13);
INSERT INTO public.hourly_price VALUES ('2023-04-23 07:00:00+03', 4.19);
INSERT INTO public.hourly_price VALUES ('2023-04-23 08:00:00+03', 4.34);
INSERT INTO public.hourly_price VALUES ('2023-04-23 09:00:00+03', 4.37);
INSERT INTO public.hourly_price VALUES ('2023-04-23 10:00:00+03', 4.46);
INSERT INTO public.hourly_price VALUES ('2023-04-23 11:00:00+03', 4.46);
INSERT INTO public.hourly_price VALUES ('2023-04-23 12:00:00+03', 4.45);
INSERT INTO public.hourly_price VALUES ('2023-04-23 13:00:00+03', 4.57);
INSERT INTO public.hourly_price VALUES ('2023-04-23 14:00:00+03', 4.53);
INSERT INTO public.hourly_price VALUES ('2023-04-23 15:00:00+03', 4.57);
INSERT INTO public.hourly_price VALUES ('2023-04-23 16:00:00+03', 3.96);
INSERT INTO public.hourly_price VALUES ('2023-04-23 17:00:00+03', 1.13);
INSERT INTO public.hourly_price VALUES ('2023-04-23 18:00:00+03', 0.55);
INSERT INTO public.hourly_price VALUES ('2023-04-23 19:00:00+03', 3.8);
INSERT INTO public.hourly_price VALUES ('2023-04-23 20:00:00+03', 4.49);
INSERT INTO public.hourly_price VALUES ('2023-04-23 21:00:00+03', 4.51);
INSERT INTO public.hourly_price VALUES ('2023-04-23 22:00:00+03', 4.5);
INSERT INTO public.hourly_price VALUES ('2023-04-23 23:00:00+03', 4.61);
INSERT INTO public.hourly_price VALUES ('2023-04-24 00:00:00+03', 4.56);
INSERT INTO public.hourly_price VALUES ('2023-04-24 01:00:00+03', 4.5);
INSERT INTO public.hourly_price VALUES ('2023-04-24 02:00:00+03', 4.29);
INSERT INTO public.hourly_price VALUES ('2023-04-24 03:00:00+03', 3.85);
INSERT INTO public.hourly_price VALUES ('2023-04-24 04:00:00+03', 4.27);
INSERT INTO public.hourly_price VALUES ('2023-04-24 05:00:00+03', 4.07);
INSERT INTO public.hourly_price VALUES ('2023-04-24 06:00:00+03', 4.03);
INSERT INTO public.hourly_price VALUES ('2023-04-24 07:00:00+03', 4.1);
INSERT INTO public.hourly_price VALUES ('2023-04-24 08:00:00+03', 4.45);
INSERT INTO public.hourly_price VALUES ('2023-04-24 09:00:00+03', 5.49);
INSERT INTO public.hourly_price VALUES ('2023-04-24 10:00:00+03', 6.61);
INSERT INTO public.hourly_price VALUES ('2023-04-24 11:00:00+03', 7.71);
INSERT INTO public.hourly_price VALUES ('2023-04-24 12:00:00+03', 8.56);
INSERT INTO public.hourly_price VALUES ('2023-04-24 13:00:00+03', 8.65);
INSERT INTO public.hourly_price VALUES ('2023-04-24 14:00:00+03', 8.73);
INSERT INTO public.hourly_price VALUES ('2023-04-24 15:00:00+03', 9.18);
INSERT INTO public.hourly_price VALUES ('2023-04-24 16:00:00+03', 8.83);
INSERT INTO public.hourly_price VALUES ('2023-04-24 17:00:00+03', 8.7);
INSERT INTO public.hourly_price VALUES ('2023-04-24 18:00:00+03', 8.63);
INSERT INTO public.hourly_price VALUES ('2023-04-24 19:00:00+03', 8.51);
INSERT INTO public.hourly_price VALUES ('2023-04-24 20:00:00+03', 8.87);
INSERT INTO public.hourly_price VALUES ('2023-04-24 21:00:00+03', 9.63);
INSERT INTO public.hourly_price VALUES ('2023-04-24 22:00:00+03', 9.83);
INSERT INTO public.hourly_price VALUES ('2023-04-24 23:00:00+03', 9.28);
INSERT INTO public.hourly_price VALUES ('2023-04-25 00:00:00+03', 8.39);
INSERT INTO public.hourly_price VALUES ('2023-04-25 01:00:00+03', 7.69);
INSERT INTO public.hourly_price VALUES ('2023-04-25 02:00:00+03', 6.69);
INSERT INTO public.hourly_price VALUES ('2023-04-25 03:00:00+03', 5.05);
INSERT INTO public.hourly_price VALUES ('2023-04-25 04:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-04-25 05:00:00+03', 5.53);
INSERT INTO public.hourly_price VALUES ('2023-04-25 06:00:00+03', 4.89);
INSERT INTO public.hourly_price VALUES ('2023-04-25 07:00:00+03', 4.66);
INSERT INTO public.hourly_price VALUES ('2023-04-25 08:00:00+03', 4.72);
INSERT INTO public.hourly_price VALUES ('2023-04-25 09:00:00+03', 4.86);
INSERT INTO public.hourly_price VALUES ('2023-04-25 10:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-04-25 11:00:00+03', 7.89);
INSERT INTO public.hourly_price VALUES ('2023-04-25 12:00:00+03', 8.01);
INSERT INTO public.hourly_price VALUES ('2023-04-25 13:00:00+03', 6.31);
INSERT INTO public.hourly_price VALUES ('2023-04-25 14:00:00+03', 4.91);
INSERT INTO public.hourly_price VALUES ('2023-04-25 15:00:00+03', 3.91);
INSERT INTO public.hourly_price VALUES ('2023-04-25 16:00:00+03', 3.84);
INSERT INTO public.hourly_price VALUES ('2023-04-25 17:00:00+03', 2.74);
INSERT INTO public.hourly_price VALUES ('2023-04-25 18:00:00+03', 1.53);
INSERT INTO public.hourly_price VALUES ('2023-04-25 19:00:00+03', 1.57);
INSERT INTO public.hourly_price VALUES ('2023-04-25 20:00:00+03', 2.28);
INSERT INTO public.hourly_price VALUES ('2023-04-25 21:00:00+03', 3.58);
INSERT INTO public.hourly_price VALUES ('2023-04-25 22:00:00+03', 3.93);
INSERT INTO public.hourly_price VALUES ('2023-04-25 23:00:00+03', 3.93);
INSERT INTO public.hourly_price VALUES ('2023-04-26 00:00:00+03', 3.86);
INSERT INTO public.hourly_price VALUES ('2023-04-26 01:00:00+03', 3.69);
INSERT INTO public.hourly_price VALUES ('2023-04-26 02:00:00+03', 2.24);
INSERT INTO public.hourly_price VALUES ('2023-04-26 03:00:00+03', 1.12);
INSERT INTO public.hourly_price VALUES ('2023-04-26 04:00:00+03', 4.41);
INSERT INTO public.hourly_price VALUES ('2023-04-26 05:00:00+03', 4.34);
INSERT INTO public.hourly_price VALUES ('2023-04-26 06:00:00+03', 4.33);
INSERT INTO public.hourly_price VALUES ('2023-04-26 07:00:00+03', 4.23);
INSERT INTO public.hourly_price VALUES ('2023-04-26 08:00:00+03', 4.26);
INSERT INTO public.hourly_price VALUES ('2023-04-26 09:00:00+03', 4.87);
INSERT INTO public.hourly_price VALUES ('2023-04-26 10:00:00+03', 6.68);
INSERT INTO public.hourly_price VALUES ('2023-04-26 11:00:00+03', 8.59);
INSERT INTO public.hourly_price VALUES ('2023-04-26 12:00:00+03', 9.05);
INSERT INTO public.hourly_price VALUES ('2023-04-26 13:00:00+03', 8.43);
INSERT INTO public.hourly_price VALUES ('2023-04-26 14:00:00+03', 8.35);
INSERT INTO public.hourly_price VALUES ('2023-04-26 15:00:00+03', 6.47);
INSERT INTO public.hourly_price VALUES ('2023-04-26 16:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-04-26 17:00:00+03', 4.9);
INSERT INTO public.hourly_price VALUES ('2023-04-26 18:00:00+03', 4.53);
INSERT INTO public.hourly_price VALUES ('2023-04-26 19:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-04-26 20:00:00+03', 4.67);
INSERT INTO public.hourly_price VALUES ('2023-04-26 21:00:00+03', 7.46);
INSERT INTO public.hourly_price VALUES ('2023-04-26 22:00:00+03', 7.8);
INSERT INTO public.hourly_price VALUES ('2023-04-26 23:00:00+03', 8.21);
INSERT INTO public.hourly_price VALUES ('2023-04-27 00:00:00+03', 8.4);
INSERT INTO public.hourly_price VALUES ('2023-04-27 01:00:00+03', 8.39);
INSERT INTO public.hourly_price VALUES ('2023-04-27 02:00:00+03', 7.4);
INSERT INTO public.hourly_price VALUES ('2023-04-27 03:00:00+03', 4.96);
INSERT INTO public.hourly_price VALUES ('2023-04-27 04:00:00+03', 10.54);
INSERT INTO public.hourly_price VALUES ('2023-04-27 05:00:00+03', 9.99);
INSERT INTO public.hourly_price VALUES ('2023-04-27 06:00:00+03', 9.57);
INSERT INTO public.hourly_price VALUES ('2023-04-27 07:00:00+03', 9.47);
INSERT INTO public.hourly_price VALUES ('2023-04-27 08:00:00+03', 9.45);
INSERT INTO public.hourly_price VALUES ('2023-04-27 09:00:00+03', 10.99);
INSERT INTO public.hourly_price VALUES ('2023-04-27 10:00:00+03', 12.85);
INSERT INTO public.hourly_price VALUES ('2023-04-27 11:00:00+03', 15.7);
INSERT INTO public.hourly_price VALUES ('2023-04-27 12:00:00+03', 14.56);
INSERT INTO public.hourly_price VALUES ('2023-04-27 13:00:00+03', 11.59);
INSERT INTO public.hourly_price VALUES ('2023-04-27 14:00:00+03', 10.6);
INSERT INTO public.hourly_price VALUES ('2023-04-27 15:00:00+03', 10.31);
INSERT INTO public.hourly_price VALUES ('2023-04-27 16:00:00+03', 9.96);
INSERT INTO public.hourly_price VALUES ('2023-04-27 17:00:00+03', 9.89);
INSERT INTO public.hourly_price VALUES ('2023-04-27 18:00:00+03', 9.94);
INSERT INTO public.hourly_price VALUES ('2023-04-27 19:00:00+03', 9.78);
INSERT INTO public.hourly_price VALUES ('2023-04-27 20:00:00+03', 9.76);
INSERT INTO public.hourly_price VALUES ('2023-04-27 21:00:00+03', 10.76);
INSERT INTO public.hourly_price VALUES ('2023-04-27 22:00:00+03', 11.69);
INSERT INTO public.hourly_price VALUES ('2023-04-27 23:00:00+03', 11.27);
INSERT INTO public.hourly_price VALUES ('2023-04-28 00:00:00+03', 10.61);
INSERT INTO public.hourly_price VALUES ('2023-04-28 01:00:00+03', 10.65);
INSERT INTO public.hourly_price VALUES ('2023-04-28 02:00:00+03', 10.71);
INSERT INTO public.hourly_price VALUES ('2023-04-28 03:00:00+03', 10.67);
INSERT INTO public.hourly_price VALUES ('2023-04-28 04:00:00+03', 8.81);
INSERT INTO public.hourly_price VALUES ('2023-04-28 05:00:00+03', 8.36);
INSERT INTO public.hourly_price VALUES ('2023-04-28 06:00:00+03', 8.27);
INSERT INTO public.hourly_price VALUES ('2023-04-28 07:00:00+03', 8.8);
INSERT INTO public.hourly_price VALUES ('2023-04-28 08:00:00+03', 9.61);
INSERT INTO public.hourly_price VALUES ('2023-04-28 09:00:00+03', 10.47);
INSERT INTO public.hourly_price VALUES ('2023-04-28 10:00:00+03', 11.88);
INSERT INTO public.hourly_price VALUES ('2023-04-28 11:00:00+03', 13.2);
INSERT INTO public.hourly_price VALUES ('2023-04-28 12:00:00+03', 13.95);
INSERT INTO public.hourly_price VALUES ('2023-04-28 13:00:00+03', 12.89);
INSERT INTO public.hourly_price VALUES ('2023-04-28 14:00:00+03', 12.06);
INSERT INTO public.hourly_price VALUES ('2023-04-28 15:00:00+03', 11.68);
INSERT INTO public.hourly_price VALUES ('2023-04-28 16:00:00+03', 11.23);
INSERT INTO public.hourly_price VALUES ('2023-04-28 17:00:00+03', 10.24);
INSERT INTO public.hourly_price VALUES ('2023-04-28 18:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-04-28 19:00:00+03', 9.79);
INSERT INTO public.hourly_price VALUES ('2023-04-28 20:00:00+03', 9.97);
INSERT INTO public.hourly_price VALUES ('2023-04-28 21:00:00+03', 10.91);
INSERT INTO public.hourly_price VALUES ('2023-04-28 22:00:00+03', 11.37);
INSERT INTO public.hourly_price VALUES ('2023-04-28 23:00:00+03', 10.87);
INSERT INTO public.hourly_price VALUES ('2023-04-29 00:00:00+03', 10.65);
INSERT INTO public.hourly_price VALUES ('2023-04-29 01:00:00+03', 11.61);
INSERT INTO public.hourly_price VALUES ('2023-04-29 02:00:00+03', 10.44);
INSERT INTO public.hourly_price VALUES ('2023-04-29 03:00:00+03', 9.71);
INSERT INTO public.hourly_price VALUES ('2023-04-29 04:00:00+03', 9.85);
INSERT INTO public.hourly_price VALUES ('2023-04-29 05:00:00+03', 9.72);
INSERT INTO public.hourly_price VALUES ('2023-04-29 06:00:00+03', 9.52);
INSERT INTO public.hourly_price VALUES ('2023-04-29 07:00:00+03', 9.5);
INSERT INTO public.hourly_price VALUES ('2023-04-29 08:00:00+03', 9.42);
INSERT INTO public.hourly_price VALUES ('2023-04-29 09:00:00+03', 9.3);
INSERT INTO public.hourly_price VALUES ('2023-04-29 10:00:00+03', 9.37);
INSERT INTO public.hourly_price VALUES ('2023-04-29 11:00:00+03', 9.71);
INSERT INTO public.hourly_price VALUES ('2023-04-29 12:00:00+03', 9.82);
INSERT INTO public.hourly_price VALUES ('2023-04-29 13:00:00+03', 9.87);
INSERT INTO public.hourly_price VALUES ('2023-04-29 14:00:00+03', 9.39);
INSERT INTO public.hourly_price VALUES ('2023-04-29 15:00:00+03', 8.42);
INSERT INTO public.hourly_price VALUES ('2023-04-29 16:00:00+03', 7.08);
INSERT INTO public.hourly_price VALUES ('2023-04-29 17:00:00+03', 5.25);
INSERT INTO public.hourly_price VALUES ('2023-04-29 18:00:00+03', 4.67);
INSERT INTO public.hourly_price VALUES ('2023-04-29 19:00:00+03', 4.46);
INSERT INTO public.hourly_price VALUES ('2023-04-29 20:00:00+03', 4.67);
INSERT INTO public.hourly_price VALUES ('2023-04-29 21:00:00+03', 4.7);
INSERT INTO public.hourly_price VALUES ('2023-04-29 22:00:00+03', 5.22);
INSERT INTO public.hourly_price VALUES ('2023-04-29 23:00:00+03', 4.99);
INSERT INTO public.hourly_price VALUES ('2023-04-30 00:00:00+03', 4.83);
INSERT INTO public.hourly_price VALUES ('2023-04-30 01:00:00+03', 4.55);
INSERT INTO public.hourly_price VALUES ('2023-04-30 02:00:00+03', 3.17);
INSERT INTO public.hourly_price VALUES ('2023-04-30 03:00:00+03', 2.8);
INSERT INTO public.hourly_price VALUES ('2023-04-30 04:00:00+03', 3.11);
INSERT INTO public.hourly_price VALUES ('2023-04-30 05:00:00+03', 3.07);
INSERT INTO public.hourly_price VALUES ('2023-04-30 06:00:00+03', 2.94);
INSERT INTO public.hourly_price VALUES ('2023-04-30 07:00:00+03', 2.9);
INSERT INTO public.hourly_price VALUES ('2023-04-30 08:00:00+03', 2.92);
INSERT INTO public.hourly_price VALUES ('2023-04-30 09:00:00+03', 2.87);
INSERT INTO public.hourly_price VALUES ('2023-04-30 10:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-04-30 11:00:00+03', 3.08);
INSERT INTO public.hourly_price VALUES ('2023-04-30 12:00:00+03', 3.44);
INSERT INTO public.hourly_price VALUES ('2023-04-30 13:00:00+03', 3.33);
INSERT INTO public.hourly_price VALUES ('2023-04-30 14:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-04-30 15:00:00+03', 0.66);
INSERT INTO public.hourly_price VALUES ('2023-04-30 16:00:00+03', 0.11);
INSERT INTO public.hourly_price VALUES ('2023-04-30 17:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-04-30 18:00:00+03', -0.09);
INSERT INTO public.hourly_price VALUES ('2023-04-30 19:00:00+03', 0.13);
INSERT INTO public.hourly_price VALUES ('2023-04-30 20:00:00+03', 1.54);
INSERT INTO public.hourly_price VALUES ('2023-04-30 21:00:00+03', 3.53);
INSERT INTO public.hourly_price VALUES ('2023-04-30 22:00:00+03', 4.28);
INSERT INTO public.hourly_price VALUES ('2023-04-30 23:00:00+03', 4.43);
INSERT INTO public.hourly_price VALUES ('2023-05-01 00:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-05-01 01:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-05-01 02:00:00+03', 3.75);
INSERT INTO public.hourly_price VALUES ('2023-05-01 03:00:00+03', 3.47);
INSERT INTO public.hourly_price VALUES ('2023-05-01 04:00:00+03', 3.9);
INSERT INTO public.hourly_price VALUES ('2023-05-01 05:00:00+03', 4.22);
INSERT INTO public.hourly_price VALUES ('2023-05-01 06:00:00+03', 4.55);
INSERT INTO public.hourly_price VALUES ('2023-05-01 07:00:00+03', 4.95);
INSERT INTO public.hourly_price VALUES ('2023-05-01 08:00:00+03', 5.28);
INSERT INTO public.hourly_price VALUES ('2023-05-01 09:00:00+03', 5.56);
INSERT INTO public.hourly_price VALUES ('2023-05-01 10:00:00+03', 5.94);
INSERT INTO public.hourly_price VALUES ('2023-05-01 11:00:00+03', 6.96);
INSERT INTO public.hourly_price VALUES ('2023-05-01 12:00:00+03', 8.13);
INSERT INTO public.hourly_price VALUES ('2023-05-01 13:00:00+03', 6.21);
INSERT INTO public.hourly_price VALUES ('2023-05-01 14:00:00+03', 6.13);
INSERT INTO public.hourly_price VALUES ('2023-05-01 15:00:00+03', 5.49);
INSERT INTO public.hourly_price VALUES ('2023-05-01 16:00:00+03', 5.2);
INSERT INTO public.hourly_price VALUES ('2023-05-01 17:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-05-01 18:00:00+03', 3.71);
INSERT INTO public.hourly_price VALUES ('2023-05-01 19:00:00+03', 4.98);
INSERT INTO public.hourly_price VALUES ('2023-05-01 20:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-05-01 21:00:00+03', 8.15);
INSERT INTO public.hourly_price VALUES ('2023-05-01 22:00:00+03', 9.3);
INSERT INTO public.hourly_price VALUES ('2023-05-01 23:00:00+03', 9.48);
INSERT INTO public.hourly_price VALUES ('2023-05-02 00:00:00+03', 9.3);
INSERT INTO public.hourly_price VALUES ('2023-05-02 01:00:00+03', 8.97);
INSERT INTO public.hourly_price VALUES ('2023-05-02 02:00:00+03', 7.99);
INSERT INTO public.hourly_price VALUES ('2023-05-02 03:00:00+03', 7.1);
INSERT INTO public.hourly_price VALUES ('2023-05-02 04:00:00+03', 8.63);
INSERT INTO public.hourly_price VALUES ('2023-05-02 05:00:00+03', 8.08);
INSERT INTO public.hourly_price VALUES ('2023-05-02 06:00:00+03', 7.62);
INSERT INTO public.hourly_price VALUES ('2023-05-02 07:00:00+03', 7.21);
INSERT INTO public.hourly_price VALUES ('2023-05-02 08:00:00+03', 7.24);
INSERT INTO public.hourly_price VALUES ('2023-05-02 09:00:00+03', 8.14);
INSERT INTO public.hourly_price VALUES ('2023-05-02 10:00:00+03', 12.43);
INSERT INTO public.hourly_price VALUES ('2023-05-02 11:00:00+03', 15.29);
INSERT INTO public.hourly_price VALUES ('2023-05-02 12:00:00+03', 16.24);
INSERT INTO public.hourly_price VALUES ('2023-05-02 13:00:00+03', 14.81);
INSERT INTO public.hourly_price VALUES ('2023-05-02 14:00:00+03', 13.89);
INSERT INTO public.hourly_price VALUES ('2023-05-02 15:00:00+03', 13.12);
INSERT INTO public.hourly_price VALUES ('2023-05-02 16:00:00+03', 11.92);
INSERT INTO public.hourly_price VALUES ('2023-05-02 17:00:00+03', 11.41);
INSERT INTO public.hourly_price VALUES ('2023-05-02 18:00:00+03', 10.69);
INSERT INTO public.hourly_price VALUES ('2023-05-02 19:00:00+03', 9.96);
INSERT INTO public.hourly_price VALUES ('2023-05-02 20:00:00+03', 10.52);
INSERT INTO public.hourly_price VALUES ('2023-05-02 21:00:00+03', 11.43);
INSERT INTO public.hourly_price VALUES ('2023-05-02 22:00:00+03', 13.23);
INSERT INTO public.hourly_price VALUES ('2023-05-02 23:00:00+03', 12.82);
INSERT INTO public.hourly_price VALUES ('2023-05-03 00:00:00+03', 11.33);
INSERT INTO public.hourly_price VALUES ('2023-05-03 01:00:00+03', 8.89);
INSERT INTO public.hourly_price VALUES ('2023-05-03 02:00:00+03', 6.82);
INSERT INTO public.hourly_price VALUES ('2023-05-03 03:00:00+03', 6.07);
INSERT INTO public.hourly_price VALUES ('2023-05-03 04:00:00+03', 1.32);
INSERT INTO public.hourly_price VALUES ('2023-05-03 05:00:00+03', 0.93);
INSERT INTO public.hourly_price VALUES ('2023-05-03 06:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-05-03 07:00:00+03', 2.15);
INSERT INTO public.hourly_price VALUES ('2023-05-03 08:00:00+03', 3.71);
INSERT INTO public.hourly_price VALUES ('2023-05-03 09:00:00+03', 6.17);
INSERT INTO public.hourly_price VALUES ('2023-05-03 10:00:00+03', 6.62);
INSERT INTO public.hourly_price VALUES ('2023-05-03 11:00:00+03', 8.38);
INSERT INTO public.hourly_price VALUES ('2023-05-03 12:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-05-03 13:00:00+03', 8.76);
INSERT INTO public.hourly_price VALUES ('2023-05-03 14:00:00+03', 7.96);
INSERT INTO public.hourly_price VALUES ('2023-05-03 15:00:00+03', 7.43);
INSERT INTO public.hourly_price VALUES ('2023-05-03 16:00:00+03', 6.87);
INSERT INTO public.hourly_price VALUES ('2023-05-03 17:00:00+03', 6.54);
INSERT INTO public.hourly_price VALUES ('2023-05-03 18:00:00+03', 6.39);
INSERT INTO public.hourly_price VALUES ('2023-05-03 19:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-05-03 20:00:00+03', 6.55);
INSERT INTO public.hourly_price VALUES ('2023-05-03 21:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-05-03 22:00:00+03', 8.22);
INSERT INTO public.hourly_price VALUES ('2023-05-03 23:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-05-04 00:00:00+03', 10.21);
INSERT INTO public.hourly_price VALUES ('2023-05-04 01:00:00+03', 9.97);
INSERT INTO public.hourly_price VALUES ('2023-05-04 02:00:00+03', 8.37);
INSERT INTO public.hourly_price VALUES ('2023-05-04 03:00:00+03', 6.63);
INSERT INTO public.hourly_price VALUES ('2023-05-04 04:00:00+03', 8.27);
INSERT INTO public.hourly_price VALUES ('2023-05-04 05:00:00+03', 8.27);
INSERT INTO public.hourly_price VALUES ('2023-05-04 06:00:00+03', 8.04);
INSERT INTO public.hourly_price VALUES ('2023-05-04 07:00:00+03', 8.27);
INSERT INTO public.hourly_price VALUES ('2023-05-04 08:00:00+03', 8.33);
INSERT INTO public.hourly_price VALUES ('2023-05-04 09:00:00+03', 9.49);
INSERT INTO public.hourly_price VALUES ('2023-05-04 10:00:00+03', 12.58);
INSERT INTO public.hourly_price VALUES ('2023-05-04 11:00:00+03', 15.48);
INSERT INTO public.hourly_price VALUES ('2023-05-04 12:00:00+03', 14.55);
INSERT INTO public.hourly_price VALUES ('2023-05-04 13:00:00+03', 12.95);
INSERT INTO public.hourly_price VALUES ('2023-05-04 14:00:00+03', 11.16);
INSERT INTO public.hourly_price VALUES ('2023-05-04 15:00:00+03', 9.87);
INSERT INTO public.hourly_price VALUES ('2023-05-04 16:00:00+03', 8.9);
INSERT INTO public.hourly_price VALUES ('2023-05-04 17:00:00+03', 7.71);
INSERT INTO public.hourly_price VALUES ('2023-05-04 18:00:00+03', 7.26);
INSERT INTO public.hourly_price VALUES ('2023-05-04 19:00:00+03', 8.29);
INSERT INTO public.hourly_price VALUES ('2023-05-04 20:00:00+03', 9.8);
INSERT INTO public.hourly_price VALUES ('2023-05-04 21:00:00+03', 12.27);
INSERT INTO public.hourly_price VALUES ('2023-05-04 22:00:00+03', 13.17);
INSERT INTO public.hourly_price VALUES ('2023-05-04 23:00:00+03', 14.23);
INSERT INTO public.hourly_price VALUES ('2023-05-05 00:00:00+03', 14.51);
INSERT INTO public.hourly_price VALUES ('2023-05-05 01:00:00+03', 13.73);
INSERT INTO public.hourly_price VALUES ('2023-05-05 02:00:00+03', 12.63);
INSERT INTO public.hourly_price VALUES ('2023-05-05 03:00:00+03', 11.11);
INSERT INTO public.hourly_price VALUES ('2023-05-05 04:00:00+03', 10.15);
INSERT INTO public.hourly_price VALUES ('2023-05-05 05:00:00+03', 9.55);
INSERT INTO public.hourly_price VALUES ('2023-05-05 06:00:00+03', 9.43);
INSERT INTO public.hourly_price VALUES ('2023-05-05 07:00:00+03', 9.54);
INSERT INTO public.hourly_price VALUES ('2023-05-05 08:00:00+03', 9.46);
INSERT INTO public.hourly_price VALUES ('2023-05-05 09:00:00+03', 10.59);
INSERT INTO public.hourly_price VALUES ('2023-05-05 10:00:00+03', 11.66);
INSERT INTO public.hourly_price VALUES ('2023-05-05 11:00:00+03', 12.64);
INSERT INTO public.hourly_price VALUES ('2023-05-05 12:00:00+03', 11.91);
INSERT INTO public.hourly_price VALUES ('2023-05-05 13:00:00+03', 11.24);
INSERT INTO public.hourly_price VALUES ('2023-05-05 14:00:00+03', 10.91);
INSERT INTO public.hourly_price VALUES ('2023-05-05 15:00:00+03', 10.18);
INSERT INTO public.hourly_price VALUES ('2023-05-05 16:00:00+03', 9.62);
INSERT INTO public.hourly_price VALUES ('2023-05-05 17:00:00+03', 9.52);
INSERT INTO public.hourly_price VALUES ('2023-05-05 18:00:00+03', 9.55);
INSERT INTO public.hourly_price VALUES ('2023-05-05 19:00:00+03', 9.81);
INSERT INTO public.hourly_price VALUES ('2023-05-05 20:00:00+03', 10.47);
INSERT INTO public.hourly_price VALUES ('2023-05-05 21:00:00+03', 10.04);
INSERT INTO public.hourly_price VALUES ('2023-05-05 22:00:00+03', 10.04);
INSERT INTO public.hourly_price VALUES ('2023-05-05 23:00:00+03', 10.04);
INSERT INTO public.hourly_price VALUES ('2023-05-06 00:00:00+03', 9.94);
INSERT INTO public.hourly_price VALUES ('2023-05-06 01:00:00+03', 10.38);
INSERT INTO public.hourly_price VALUES ('2023-05-06 02:00:00+03', 9.69);
INSERT INTO public.hourly_price VALUES ('2023-05-06 03:00:00+03', 9.01);
INSERT INTO public.hourly_price VALUES ('2023-05-06 04:00:00+03', 8.43);
INSERT INTO public.hourly_price VALUES ('2023-05-06 05:00:00+03', 7.92);
INSERT INTO public.hourly_price VALUES ('2023-05-06 06:00:00+03', 7.8);
INSERT INTO public.hourly_price VALUES ('2023-05-06 07:00:00+03', 8.04);
INSERT INTO public.hourly_price VALUES ('2023-05-06 08:00:00+03', 8.14);
INSERT INTO public.hourly_price VALUES ('2023-05-06 09:00:00+03', 8.6);
INSERT INTO public.hourly_price VALUES ('2023-05-06 10:00:00+03', 9.19);
INSERT INTO public.hourly_price VALUES ('2023-05-06 11:00:00+03', 9.57);
INSERT INTO public.hourly_price VALUES ('2023-05-06 12:00:00+03', 10.49);
INSERT INTO public.hourly_price VALUES ('2023-05-06 13:00:00+03', 9.84);
INSERT INTO public.hourly_price VALUES ('2023-05-06 14:00:00+03', 9.65);
INSERT INTO public.hourly_price VALUES ('2023-05-06 15:00:00+03', 9.01);
INSERT INTO public.hourly_price VALUES ('2023-05-06 16:00:00+03', 8.72);
INSERT INTO public.hourly_price VALUES ('2023-05-06 17:00:00+03', 6.91);
INSERT INTO public.hourly_price VALUES ('2023-05-06 18:00:00+03', 6.2);
INSERT INTO public.hourly_price VALUES ('2023-05-06 19:00:00+03', 7.83);
INSERT INTO public.hourly_price VALUES ('2023-05-06 20:00:00+03', 9.03);
INSERT INTO public.hourly_price VALUES ('2023-05-06 21:00:00+03', 9.67);
INSERT INTO public.hourly_price VALUES ('2023-05-06 22:00:00+03', 10.12);
INSERT INTO public.hourly_price VALUES ('2023-05-06 23:00:00+03', 10.55);
INSERT INTO public.hourly_price VALUES ('2023-05-07 00:00:00+03', 10.26);
INSERT INTO public.hourly_price VALUES ('2023-05-07 01:00:00+03', 9.73);
INSERT INTO public.hourly_price VALUES ('2023-05-07 02:00:00+03', 9.72);
INSERT INTO public.hourly_price VALUES ('2023-05-07 03:00:00+03', 9.07);
INSERT INTO public.hourly_price VALUES ('2023-05-07 04:00:00+03', 7.61);
INSERT INTO public.hourly_price VALUES ('2023-05-07 05:00:00+03', 7.66);
INSERT INTO public.hourly_price VALUES ('2023-05-07 06:00:00+03', 7.65);
INSERT INTO public.hourly_price VALUES ('2023-05-07 07:00:00+03', 7.69);
INSERT INTO public.hourly_price VALUES ('2023-05-07 08:00:00+03', 7.9);
INSERT INTO public.hourly_price VALUES ('2023-05-07 09:00:00+03', 8);
INSERT INTO public.hourly_price VALUES ('2023-05-07 10:00:00+03', 8.19);
INSERT INTO public.hourly_price VALUES ('2023-05-07 11:00:00+03', 9.72);
INSERT INTO public.hourly_price VALUES ('2023-05-07 12:00:00+03', 9.41);
INSERT INTO public.hourly_price VALUES ('2023-05-07 13:00:00+03', 8.38);
INSERT INTO public.hourly_price VALUES ('2023-05-07 14:00:00+03', 4.64);
INSERT INTO public.hourly_price VALUES ('2023-05-07 15:00:00+03', 3.78);
INSERT INTO public.hourly_price VALUES ('2023-05-07 16:00:00+03', 4.87);
INSERT INTO public.hourly_price VALUES ('2023-05-07 17:00:00+03', 4.35);
INSERT INTO public.hourly_price VALUES ('2023-05-07 18:00:00+03', 3.8);
INSERT INTO public.hourly_price VALUES ('2023-05-07 19:00:00+03', 3.73);
INSERT INTO public.hourly_price VALUES ('2023-05-07 20:00:00+03', 7.02);
INSERT INTO public.hourly_price VALUES ('2023-05-07 21:00:00+03', 8.54);
INSERT INTO public.hourly_price VALUES ('2023-05-07 22:00:00+03', 8.95);
INSERT INTO public.hourly_price VALUES ('2023-05-07 23:00:00+03', 8.96);
INSERT INTO public.hourly_price VALUES ('2023-05-08 00:00:00+03', 8.42);
INSERT INTO public.hourly_price VALUES ('2023-05-08 01:00:00+03', 8.19);
INSERT INTO public.hourly_price VALUES ('2023-05-08 02:00:00+03', 8.28);
INSERT INTO public.hourly_price VALUES ('2023-05-08 03:00:00+03', 7.64);
INSERT INTO public.hourly_price VALUES ('2023-05-08 04:00:00+03', 6.98);
INSERT INTO public.hourly_price VALUES ('2023-05-08 05:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-05-08 06:00:00+03', 7.03);
INSERT INTO public.hourly_price VALUES ('2023-05-08 07:00:00+03', 7.37);
INSERT INTO public.hourly_price VALUES ('2023-05-08 08:00:00+03', 7.8);
INSERT INTO public.hourly_price VALUES ('2023-05-08 09:00:00+03', 8.43);
INSERT INTO public.hourly_price VALUES ('2023-05-08 10:00:00+03', 9.91);
INSERT INTO public.hourly_price VALUES ('2023-05-08 11:00:00+03', 14.08);
INSERT INTO public.hourly_price VALUES ('2023-05-08 12:00:00+03', 13.33);
INSERT INTO public.hourly_price VALUES ('2023-05-08 13:00:00+03', 12.02);
INSERT INTO public.hourly_price VALUES ('2023-05-08 14:00:00+03', 11.11);
INSERT INTO public.hourly_price VALUES ('2023-05-08 15:00:00+03', 9.88);
INSERT INTO public.hourly_price VALUES ('2023-05-08 16:00:00+03', 9.31);
INSERT INTO public.hourly_price VALUES ('2023-05-08 17:00:00+03', 8.62);
INSERT INTO public.hourly_price VALUES ('2023-05-08 18:00:00+03', 7.8);
INSERT INTO public.hourly_price VALUES ('2023-05-08 19:00:00+03', 7.47);
INSERT INTO public.hourly_price VALUES ('2023-05-08 20:00:00+03', 7.48);
INSERT INTO public.hourly_price VALUES ('2023-05-08 21:00:00+03', 7.69);
INSERT INTO public.hourly_price VALUES ('2023-05-08 22:00:00+03', 8.04);
INSERT INTO public.hourly_price VALUES ('2023-05-08 23:00:00+03', 7.79);
INSERT INTO public.hourly_price VALUES ('2023-05-09 00:00:00+03', 7.09);
INSERT INTO public.hourly_price VALUES ('2023-05-09 01:00:00+03', 6.45);
INSERT INTO public.hourly_price VALUES ('2023-05-09 02:00:00+03', 5);
INSERT INTO public.hourly_price VALUES ('2023-05-09 03:00:00+03', 3.64);
INSERT INTO public.hourly_price VALUES ('2023-05-09 04:00:00+03', 2.38);
INSERT INTO public.hourly_price VALUES ('2023-05-09 05:00:00+03', 0.45);
INSERT INTO public.hourly_price VALUES ('2023-05-09 06:00:00+03', 0.36);
INSERT INTO public.hourly_price VALUES ('2023-05-09 07:00:00+03', 0.29);
INSERT INTO public.hourly_price VALUES ('2023-05-09 08:00:00+03', 0.47);
INSERT INTO public.hourly_price VALUES ('2023-05-09 09:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-05-09 10:00:00+03', 3.7);
INSERT INTO public.hourly_price VALUES ('2023-05-09 11:00:00+03', 6.37);
INSERT INTO public.hourly_price VALUES ('2023-05-09 12:00:00+03', 7.16);
INSERT INTO public.hourly_price VALUES ('2023-05-09 13:00:00+03', 5.84);
INSERT INTO public.hourly_price VALUES ('2023-05-09 14:00:00+03', 4.14);
INSERT INTO public.hourly_price VALUES ('2023-05-09 15:00:00+03', 3.58);
INSERT INTO public.hourly_price VALUES ('2023-05-09 16:00:00+03', 3.11);
INSERT INTO public.hourly_price VALUES ('2023-05-09 17:00:00+03', 1.88);
INSERT INTO public.hourly_price VALUES ('2023-05-09 18:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-05-09 19:00:00+03', 0.86);
INSERT INTO public.hourly_price VALUES ('2023-05-09 20:00:00+03', 0.78);
INSERT INTO public.hourly_price VALUES ('2023-05-09 21:00:00+03', 1.58);
INSERT INTO public.hourly_price VALUES ('2023-05-09 22:00:00+03', 2.74);
INSERT INTO public.hourly_price VALUES ('2023-05-09 23:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-05-10 00:00:00+03', 1.28);
INSERT INTO public.hourly_price VALUES ('2023-05-10 01:00:00+03', 0.72);
INSERT INTO public.hourly_price VALUES ('2023-05-10 02:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-10 03:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-10 04:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-10 05:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-10 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-10 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-10 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-10 09:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-10 10:00:00+03', 0.41);
INSERT INTO public.hourly_price VALUES ('2023-05-10 11:00:00+03', 3.64);
INSERT INTO public.hourly_price VALUES ('2023-05-10 12:00:00+03', 4.41);
INSERT INTO public.hourly_price VALUES ('2023-05-10 13:00:00+03', 3.75);
INSERT INTO public.hourly_price VALUES ('2023-05-10 14:00:00+03', 2.73);
INSERT INTO public.hourly_price VALUES ('2023-05-10 15:00:00+03', 0.49);
INSERT INTO public.hourly_price VALUES ('2023-05-10 16:00:00+03', 0.38);
INSERT INTO public.hourly_price VALUES ('2023-05-10 17:00:00+03', 0.3);
INSERT INTO public.hourly_price VALUES ('2023-05-10 18:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-05-10 19:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-05-10 20:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-10 21:00:00+03', 0.46);
INSERT INTO public.hourly_price VALUES ('2023-05-10 22:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-05-10 23:00:00+03', 1.26);
INSERT INTO public.hourly_price VALUES ('2023-05-11 00:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-11 01:00:00+03', 0.17);
INSERT INTO public.hourly_price VALUES ('2023-05-11 02:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-11 03:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-11 04:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-11 05:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-11 06:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-11 07:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-11 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-11 09:00:00+03', 0.78);
INSERT INTO public.hourly_price VALUES ('2023-05-11 10:00:00+03', 1.89);
INSERT INTO public.hourly_price VALUES ('2023-05-11 11:00:00+03', 4.28);
INSERT INTO public.hourly_price VALUES ('2023-05-11 12:00:00+03', 5.93);
INSERT INTO public.hourly_price VALUES ('2023-05-11 13:00:00+03', 5.58);
INSERT INTO public.hourly_price VALUES ('2023-05-11 14:00:00+03', 4.71);
INSERT INTO public.hourly_price VALUES ('2023-05-11 15:00:00+03', 3.62);
INSERT INTO public.hourly_price VALUES ('2023-05-11 16:00:00+03', 3.51);
INSERT INTO public.hourly_price VALUES ('2023-05-11 17:00:00+03', 3.49);
INSERT INTO public.hourly_price VALUES ('2023-05-11 18:00:00+03', 1.87);
INSERT INTO public.hourly_price VALUES ('2023-05-11 19:00:00+03', 2.68);
INSERT INTO public.hourly_price VALUES ('2023-05-11 20:00:00+03', 3.34);
INSERT INTO public.hourly_price VALUES ('2023-05-11 21:00:00+03', 3.61);
INSERT INTO public.hourly_price VALUES ('2023-05-11 22:00:00+03', 3.61);
INSERT INTO public.hourly_price VALUES ('2023-05-11 23:00:00+03', 3.53);
INSERT INTO public.hourly_price VALUES ('2023-05-12 00:00:00+03', 2.3);
INSERT INTO public.hourly_price VALUES ('2023-05-12 01:00:00+03', 1.61);
INSERT INTO public.hourly_price VALUES ('2023-05-12 02:00:00+03', 0.44);
INSERT INTO public.hourly_price VALUES ('2023-05-12 03:00:00+03', 0.05);
INSERT INTO public.hourly_price VALUES ('2023-05-12 04:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-12 05:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-12 06:00:00+03', 0.03);
INSERT INTO public.hourly_price VALUES ('2023-05-12 07:00:00+03', 0.37);
INSERT INTO public.hourly_price VALUES ('2023-05-12 08:00:00+03', 1.94);
INSERT INTO public.hourly_price VALUES ('2023-05-12 09:00:00+03', 3.33);
INSERT INTO public.hourly_price VALUES ('2023-05-12 10:00:00+03', 5.31);
INSERT INTO public.hourly_price VALUES ('2023-05-12 11:00:00+03', 10.53);
INSERT INTO public.hourly_price VALUES ('2023-05-12 12:00:00+03', 11.97);
INSERT INTO public.hourly_price VALUES ('2023-05-12 13:00:00+03', 10.46);
INSERT INTO public.hourly_price VALUES ('2023-05-12 14:00:00+03', 10.23);
INSERT INTO public.hourly_price VALUES ('2023-05-12 15:00:00+03', 8.01);
INSERT INTO public.hourly_price VALUES ('2023-05-12 16:00:00+03', 6.56);
INSERT INTO public.hourly_price VALUES ('2023-05-12 17:00:00+03', 5.48);
INSERT INTO public.hourly_price VALUES ('2023-05-12 18:00:00+03', 4.66);
INSERT INTO public.hourly_price VALUES ('2023-05-12 19:00:00+03', 4.62);
INSERT INTO public.hourly_price VALUES ('2023-05-12 20:00:00+03', 4.72);
INSERT INTO public.hourly_price VALUES ('2023-05-12 21:00:00+03', 6.15);
INSERT INTO public.hourly_price VALUES ('2023-05-12 22:00:00+03', 7.06);
INSERT INTO public.hourly_price VALUES ('2023-05-12 23:00:00+03', 7.2);
INSERT INTO public.hourly_price VALUES ('2023-05-13 00:00:00+03', 6.18);
INSERT INTO public.hourly_price VALUES ('2023-05-13 01:00:00+03', 6);
INSERT INTO public.hourly_price VALUES ('2023-05-13 02:00:00+03', 5.53);
INSERT INTO public.hourly_price VALUES ('2023-05-13 03:00:00+03', 4.84);
INSERT INTO public.hourly_price VALUES ('2023-05-13 04:00:00+03', 3.2);
INSERT INTO public.hourly_price VALUES ('2023-05-13 05:00:00+03', 3.14);
INSERT INTO public.hourly_price VALUES ('2023-05-13 06:00:00+03', 3.14);
INSERT INTO public.hourly_price VALUES ('2023-05-13 07:00:00+03', 3.23);
INSERT INTO public.hourly_price VALUES ('2023-05-13 08:00:00+03', 3.27);
INSERT INTO public.hourly_price VALUES ('2023-05-13 09:00:00+03', 3.27);
INSERT INTO public.hourly_price VALUES ('2023-05-13 10:00:00+03', 2.8);
INSERT INTO public.hourly_price VALUES ('2023-05-13 11:00:00+03', 2.85);
INSERT INTO public.hourly_price VALUES ('2023-05-13 12:00:00+03', 3.01);
INSERT INTO public.hourly_price VALUES ('2023-05-13 13:00:00+03', 3);
INSERT INTO public.hourly_price VALUES ('2023-05-13 14:00:00+03', 2.8);
INSERT INTO public.hourly_price VALUES ('2023-05-13 15:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-05-13 16:00:00+03', 1.91);
INSERT INTO public.hourly_price VALUES ('2023-05-13 17:00:00+03', 0.7);
INSERT INTO public.hourly_price VALUES ('2023-05-13 18:00:00+03', 0.63);
INSERT INTO public.hourly_price VALUES ('2023-05-13 19:00:00+03', 0.77);
INSERT INTO public.hourly_price VALUES ('2023-05-13 20:00:00+03', 2.36);
INSERT INTO public.hourly_price VALUES ('2023-05-13 21:00:00+03', 2.98);
INSERT INTO public.hourly_price VALUES ('2023-05-13 22:00:00+03', 3.13);
INSERT INTO public.hourly_price VALUES ('2023-05-13 23:00:00+03', 3.14);
INSERT INTO public.hourly_price VALUES ('2023-05-14 00:00:00+03', 2.97);
INSERT INTO public.hourly_price VALUES ('2023-05-14 01:00:00+03', 3.02);
INSERT INTO public.hourly_price VALUES ('2023-05-14 02:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-05-14 03:00:00+03', 1.55);
INSERT INTO public.hourly_price VALUES ('2023-05-14 04:00:00+03', 1.25);
INSERT INTO public.hourly_price VALUES ('2023-05-14 05:00:00+03', 1.12);
INSERT INTO public.hourly_price VALUES ('2023-05-14 06:00:00+03', 1.06);
INSERT INTO public.hourly_price VALUES ('2023-05-14 07:00:00+03', 1.04);
INSERT INTO public.hourly_price VALUES ('2023-05-14 08:00:00+03', 0.99);
INSERT INTO public.hourly_price VALUES ('2023-05-14 09:00:00+03', 1.02);
INSERT INTO public.hourly_price VALUES ('2023-05-14 10:00:00+03', 0.93);
INSERT INTO public.hourly_price VALUES ('2023-05-14 11:00:00+03', 1.08);
INSERT INTO public.hourly_price VALUES ('2023-05-14 12:00:00+03', 1.71);
INSERT INTO public.hourly_price VALUES ('2023-05-14 13:00:00+03', 1.94);
INSERT INTO public.hourly_price VALUES ('2023-05-14 14:00:00+03', 1.5);
INSERT INTO public.hourly_price VALUES ('2023-05-14 15:00:00+03', 1.15);
INSERT INTO public.hourly_price VALUES ('2023-05-14 16:00:00+03', 0.72);
INSERT INTO public.hourly_price VALUES ('2023-05-14 17:00:00+03', 0.23);
INSERT INTO public.hourly_price VALUES ('2023-05-14 18:00:00+03', 0.02);
INSERT INTO public.hourly_price VALUES ('2023-05-14 19:00:00+03', 0.22);
INSERT INTO public.hourly_price VALUES ('2023-05-14 20:00:00+03', 0.64);
INSERT INTO public.hourly_price VALUES ('2023-05-14 21:00:00+03', 1.28);
INSERT INTO public.hourly_price VALUES ('2023-05-14 22:00:00+03', 1.72);
INSERT INTO public.hourly_price VALUES ('2023-05-14 23:00:00+03', 2.04);
INSERT INTO public.hourly_price VALUES ('2023-05-15 00:00:00+03', 1.3);
INSERT INTO public.hourly_price VALUES ('2023-05-15 01:00:00+03', 0.73);
INSERT INTO public.hourly_price VALUES ('2023-05-15 02:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-05-15 03:00:00+03', 0.52);
INSERT INTO public.hourly_price VALUES ('2023-05-15 04:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-05-15 05:00:00+03', 0.57);
INSERT INTO public.hourly_price VALUES ('2023-05-15 06:00:00+03', 0.6);
INSERT INTO public.hourly_price VALUES ('2023-05-15 07:00:00+03', 0.63);
INSERT INTO public.hourly_price VALUES ('2023-05-15 08:00:00+03', 0.65);
INSERT INTO public.hourly_price VALUES ('2023-05-15 09:00:00+03', 0.83);
INSERT INTO public.hourly_price VALUES ('2023-05-15 10:00:00+03', 1.8);
INSERT INTO public.hourly_price VALUES ('2023-05-15 11:00:00+03', 11.44);
INSERT INTO public.hourly_price VALUES ('2023-05-15 12:00:00+03', 11.67);
INSERT INTO public.hourly_price VALUES ('2023-05-15 13:00:00+03', 10.61);
INSERT INTO public.hourly_price VALUES ('2023-05-15 14:00:00+03', 2.82);
INSERT INTO public.hourly_price VALUES ('2023-05-15 15:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-05-15 16:00:00+03', 1.85);
INSERT INTO public.hourly_price VALUES ('2023-05-15 17:00:00+03', 1.44);
INSERT INTO public.hourly_price VALUES ('2023-05-15 18:00:00+03', 1.11);
INSERT INTO public.hourly_price VALUES ('2023-05-15 19:00:00+03', 1.48);
INSERT INTO public.hourly_price VALUES ('2023-05-15 20:00:00+03', 1.77);
INSERT INTO public.hourly_price VALUES ('2023-05-15 21:00:00+03', 2.16);
INSERT INTO public.hourly_price VALUES ('2023-05-15 22:00:00+03', 9.96);
INSERT INTO public.hourly_price VALUES ('2023-05-15 23:00:00+03', 2.36);
INSERT INTO public.hourly_price VALUES ('2023-05-16 00:00:00+03', 2.24);
INSERT INTO public.hourly_price VALUES ('2023-05-16 01:00:00+03', 1.7);
INSERT INTO public.hourly_price VALUES ('2023-05-16 02:00:00+03', 1.16);
INSERT INTO public.hourly_price VALUES ('2023-05-16 03:00:00+03', 0.9);
INSERT INTO public.hourly_price VALUES ('2023-05-16 04:00:00+03', 0.71);
INSERT INTO public.hourly_price VALUES ('2023-05-16 05:00:00+03', 0.63);
INSERT INTO public.hourly_price VALUES ('2023-05-16 06:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-05-16 07:00:00+03', 0.64);
INSERT INTO public.hourly_price VALUES ('2023-05-16 08:00:00+03', 0.72);
INSERT INTO public.hourly_price VALUES ('2023-05-16 09:00:00+03', 1.08);
INSERT INTO public.hourly_price VALUES ('2023-05-16 10:00:00+03', 2.05);
INSERT INTO public.hourly_price VALUES ('2023-05-16 11:00:00+03', 2.94);
INSERT INTO public.hourly_price VALUES ('2023-05-16 12:00:00+03', 9.55);
INSERT INTO public.hourly_price VALUES ('2023-05-16 13:00:00+03', 3.04);
INSERT INTO public.hourly_price VALUES ('2023-05-16 14:00:00+03', 2.93);
INSERT INTO public.hourly_price VALUES ('2023-05-16 15:00:00+03', 2.71);
INSERT INTO public.hourly_price VALUES ('2023-05-16 16:00:00+03', 2);
INSERT INTO public.hourly_price VALUES ('2023-05-16 17:00:00+03', 1.62);
INSERT INTO public.hourly_price VALUES ('2023-05-16 18:00:00+03', 1.3);
INSERT INTO public.hourly_price VALUES ('2023-05-16 19:00:00+03', 1.12);
INSERT INTO public.hourly_price VALUES ('2023-05-16 20:00:00+03', 1.03);
INSERT INTO public.hourly_price VALUES ('2023-05-16 21:00:00+03', 1.07);
INSERT INTO public.hourly_price VALUES ('2023-05-16 22:00:00+03', 0.96);
INSERT INTO public.hourly_price VALUES ('2023-05-16 23:00:00+03', 0.76);
INSERT INTO public.hourly_price VALUES ('2023-05-17 00:00:00+03', 0.56);
INSERT INTO public.hourly_price VALUES ('2023-05-17 01:00:00+03', 0.49);
INSERT INTO public.hourly_price VALUES ('2023-05-17 02:00:00+03', 0.4);
INSERT INTO public.hourly_price VALUES ('2023-05-17 03:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-17 04:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-17 05:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-05-17 06:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-05-17 07:00:00+03', -0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-17 08:00:00+03', -0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-17 09:00:00+03', -0.1);
INSERT INTO public.hourly_price VALUES ('2023-05-17 10:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-17 11:00:00+03', 0.3);
INSERT INTO public.hourly_price VALUES ('2023-05-17 12:00:00+03', 0.43);
INSERT INTO public.hourly_price VALUES ('2023-05-17 13:00:00+03', 0.41);
INSERT INTO public.hourly_price VALUES ('2023-05-17 14:00:00+03', 0.37);
INSERT INTO public.hourly_price VALUES ('2023-05-17 15:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-17 16:00:00+03', 0.06);
INSERT INTO public.hourly_price VALUES ('2023-05-17 17:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-17 18:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-17 19:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-17 20:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-17 21:00:00+03', 0.06);
INSERT INTO public.hourly_price VALUES ('2023-05-17 22:00:00+03', 0.18);
INSERT INTO public.hourly_price VALUES ('2023-05-17 23:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-18 00:00:00+03', 0.03);
INSERT INTO public.hourly_price VALUES ('2023-05-18 01:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-18 02:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-18 03:00:00+03', -0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-18 04:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-18 05:00:00+03', -0.27);
INSERT INTO public.hourly_price VALUES ('2023-05-18 06:00:00+03', -0.34);
INSERT INTO public.hourly_price VALUES ('2023-05-18 07:00:00+03', -0.32);
INSERT INTO public.hourly_price VALUES ('2023-05-18 08:00:00+03', -0.26);
INSERT INTO public.hourly_price VALUES ('2023-05-18 09:00:00+03', -0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-18 10:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-05-18 11:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-18 12:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-18 13:00:00+03', 0.03);
INSERT INTO public.hourly_price VALUES ('2023-05-18 14:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-18 15:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-05-18 16:00:00+03', 0.35);
INSERT INTO public.hourly_price VALUES ('2023-05-18 17:00:00+03', 0.4);
INSERT INTO public.hourly_price VALUES ('2023-05-18 18:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-05-18 19:00:00+03', 0.57);
INSERT INTO public.hourly_price VALUES ('2023-05-18 20:00:00+03', 0.72);
INSERT INTO public.hourly_price VALUES ('2023-05-18 21:00:00+03', 1.16);
INSERT INTO public.hourly_price VALUES ('2023-05-18 22:00:00+03', 2.22);
INSERT INTO public.hourly_price VALUES ('2023-05-18 23:00:00+03', 2.32);
INSERT INTO public.hourly_price VALUES ('2023-05-19 00:00:00+03', 2.19);
INSERT INTO public.hourly_price VALUES ('2023-05-19 01:00:00+03', 1.69);
INSERT INTO public.hourly_price VALUES ('2023-05-19 02:00:00+03', 1.13);
INSERT INTO public.hourly_price VALUES ('2023-05-19 03:00:00+03', 0.73);
INSERT INTO public.hourly_price VALUES ('2023-05-19 04:00:00+03', 0.66);
INSERT INTO public.hourly_price VALUES ('2023-05-19 05:00:00+03', 0.56);
INSERT INTO public.hourly_price VALUES ('2023-05-19 06:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-05-19 07:00:00+03', 0.52);
INSERT INTO public.hourly_price VALUES ('2023-05-19 08:00:00+03', 0.49);
INSERT INTO public.hourly_price VALUES ('2023-05-19 09:00:00+03', 0.56);
INSERT INTO public.hourly_price VALUES ('2023-05-19 10:00:00+03', 10.32);
INSERT INTO public.hourly_price VALUES ('2023-05-19 11:00:00+03', 12.75);
INSERT INTO public.hourly_price VALUES ('2023-05-19 12:00:00+03', 12.64);
INSERT INTO public.hourly_price VALUES ('2023-05-19 13:00:00+03', 10.92);
INSERT INTO public.hourly_price VALUES ('2023-05-19 14:00:00+03', 4.95);
INSERT INTO public.hourly_price VALUES ('2023-05-19 15:00:00+03', 1.97);
INSERT INTO public.hourly_price VALUES ('2023-05-19 16:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-05-19 17:00:00+03', 0.9);
INSERT INTO public.hourly_price VALUES ('2023-05-19 18:00:00+03', 0.59);
INSERT INTO public.hourly_price VALUES ('2023-05-19 19:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-05-19 20:00:00+03', 0.75);
INSERT INTO public.hourly_price VALUES ('2023-05-19 21:00:00+03', 1);
INSERT INTO public.hourly_price VALUES ('2023-05-19 22:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-05-19 23:00:00+03', 1.05);
INSERT INTO public.hourly_price VALUES ('2023-05-20 00:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-05-20 01:00:00+03', 0.41);
INSERT INTO public.hourly_price VALUES ('2023-05-20 02:00:00+03', 0.23);
INSERT INTO public.hourly_price VALUES ('2023-05-20 03:00:00+03', 0.05);
INSERT INTO public.hourly_price VALUES ('2023-05-20 04:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-05-20 05:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-05-20 06:00:00+03', 0.03);
INSERT INTO public.hourly_price VALUES ('2023-05-20 07:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-20 08:00:00+03', 0.11);
INSERT INTO public.hourly_price VALUES ('2023-05-20 09:00:00+03', 0.16);
INSERT INTO public.hourly_price VALUES ('2023-05-20 10:00:00+03', 0.29);
INSERT INTO public.hourly_price VALUES ('2023-05-20 11:00:00+03', 0.54);
INSERT INTO public.hourly_price VALUES ('2023-05-20 12:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-05-20 13:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-05-20 14:00:00+03', 0.54);
INSERT INTO public.hourly_price VALUES ('2023-05-20 15:00:00+03', 0.05);
INSERT INTO public.hourly_price VALUES ('2023-05-20 16:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-05-20 17:00:00+03', -0.06);
INSERT INTO public.hourly_price VALUES ('2023-05-20 18:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-20 19:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-20 20:00:00+03', 0.16);
INSERT INTO public.hourly_price VALUES ('2023-05-20 21:00:00+03', 0.52);
INSERT INTO public.hourly_price VALUES ('2023-05-20 22:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-05-20 23:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-05-21 00:00:00+03', 0.52);
INSERT INTO public.hourly_price VALUES ('2023-05-21 01:00:00+03', 0.46);
INSERT INTO public.hourly_price VALUES ('2023-05-21 02:00:00+03', 0.29);
INSERT INTO public.hourly_price VALUES ('2023-05-21 03:00:00+03', 0.09);
INSERT INTO public.hourly_price VALUES ('2023-05-21 04:00:00+03', 0.05);
INSERT INTO public.hourly_price VALUES ('2023-05-21 05:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-21 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-21 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-21 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-21 09:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-21 10:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-05-21 11:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-05-21 12:00:00+03', 0.42);
INSERT INTO public.hourly_price VALUES ('2023-05-21 13:00:00+03', 0.27);
INSERT INTO public.hourly_price VALUES ('2023-05-21 14:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-21 15:00:00+03', -0.05);
INSERT INTO public.hourly_price VALUES ('2023-05-21 16:00:00+03', -0.39);
INSERT INTO public.hourly_price VALUES ('2023-05-21 17:00:00+03', -0.5);
INSERT INTO public.hourly_price VALUES ('2023-05-21 18:00:00+03', -0.44);
INSERT INTO public.hourly_price VALUES ('2023-05-21 19:00:00+03', -0.35);
INSERT INTO public.hourly_price VALUES ('2023-05-21 20:00:00+03', -0.04);
INSERT INTO public.hourly_price VALUES ('2023-05-21 21:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-05-21 22:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-05-21 23:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-05-22 00:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-05-22 01:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-05-22 02:00:00+03', 0.53);
INSERT INTO public.hourly_price VALUES ('2023-05-22 03:00:00+03', 0.41);
INSERT INTO public.hourly_price VALUES ('2023-05-22 04:00:00+03', 0.49);
INSERT INTO public.hourly_price VALUES ('2023-05-22 05:00:00+03', 0.49);
INSERT INTO public.hourly_price VALUES ('2023-05-22 06:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-05-22 07:00:00+03', 0.5);
INSERT INTO public.hourly_price VALUES ('2023-05-22 08:00:00+03', 0.54);
INSERT INTO public.hourly_price VALUES ('2023-05-22 09:00:00+03', 0.77);
INSERT INTO public.hourly_price VALUES ('2023-05-22 10:00:00+03', 1.66);
INSERT INTO public.hourly_price VALUES ('2023-05-22 11:00:00+03', 9.54);
INSERT INTO public.hourly_price VALUES ('2023-05-22 12:00:00+03', 10.93);
INSERT INTO public.hourly_price VALUES ('2023-05-22 13:00:00+03', 9.99);
INSERT INTO public.hourly_price VALUES ('2023-05-22 14:00:00+03', 7.11);
INSERT INTO public.hourly_price VALUES ('2023-05-22 15:00:00+03', 7.43);
INSERT INTO public.hourly_price VALUES ('2023-05-22 16:00:00+03', 2.49);
INSERT INTO public.hourly_price VALUES ('2023-05-22 17:00:00+03', 2.14);
INSERT INTO public.hourly_price VALUES ('2023-05-22 18:00:00+03', 1.99);
INSERT INTO public.hourly_price VALUES ('2023-05-22 19:00:00+03', 1.8);
INSERT INTO public.hourly_price VALUES ('2023-05-22 20:00:00+03', 1.9);
INSERT INTO public.hourly_price VALUES ('2023-05-22 21:00:00+03', 1.74);
INSERT INTO public.hourly_price VALUES ('2023-05-22 22:00:00+03', 1.72);
INSERT INTO public.hourly_price VALUES ('2023-05-22 23:00:00+03', 1.61);
INSERT INTO public.hourly_price VALUES ('2023-05-23 00:00:00+03', 1.11);
INSERT INTO public.hourly_price VALUES ('2023-05-23 01:00:00+03', 0.81);
INSERT INTO public.hourly_price VALUES ('2023-05-23 02:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-05-23 03:00:00+03', 0.39);
INSERT INTO public.hourly_price VALUES ('2023-05-23 04:00:00+03', 0.35);
INSERT INTO public.hourly_price VALUES ('2023-05-23 05:00:00+03', 0.29);
INSERT INTO public.hourly_price VALUES ('2023-05-23 06:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-23 07:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-23 08:00:00+03', 0.3);
INSERT INTO public.hourly_price VALUES ('2023-05-23 09:00:00+03', 0.48);
INSERT INTO public.hourly_price VALUES ('2023-05-23 10:00:00+03', 1.05);
INSERT INTO public.hourly_price VALUES ('2023-05-23 11:00:00+03', 2.28);
INSERT INTO public.hourly_price VALUES ('2023-05-23 12:00:00+03', 2.55);
INSERT INTO public.hourly_price VALUES ('2023-05-23 13:00:00+03', 2.58);
INSERT INTO public.hourly_price VALUES ('2023-05-23 14:00:00+03', 2.53);
INSERT INTO public.hourly_price VALUES ('2023-05-23 15:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-05-23 16:00:00+03', 2.28);
INSERT INTO public.hourly_price VALUES ('2023-05-23 17:00:00+03', 2.15);
INSERT INTO public.hourly_price VALUES ('2023-05-23 18:00:00+03', 0.71);
INSERT INTO public.hourly_price VALUES ('2023-05-23 19:00:00+03', 0.54);
INSERT INTO public.hourly_price VALUES ('2023-05-23 20:00:00+03', 1.52);
INSERT INTO public.hourly_price VALUES ('2023-05-23 21:00:00+03', 1.55);
INSERT INTO public.hourly_price VALUES ('2023-05-23 22:00:00+03', 1.61);
INSERT INTO public.hourly_price VALUES ('2023-05-23 23:00:00+03', 1.29);
INSERT INTO public.hourly_price VALUES ('2023-05-24 00:00:00+03', 0.84);
INSERT INTO public.hourly_price VALUES ('2023-05-24 01:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-05-24 02:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-05-24 03:00:00+03', 0.33);
INSERT INTO public.hourly_price VALUES ('2023-05-24 04:00:00+03', 0.3);
INSERT INTO public.hourly_price VALUES ('2023-05-24 05:00:00+03', 0.11);
INSERT INTO public.hourly_price VALUES ('2023-05-24 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-24 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-24 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-24 09:00:00+03', 0.16);
INSERT INTO public.hourly_price VALUES ('2023-05-24 10:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-05-24 11:00:00+03', 0.45);
INSERT INTO public.hourly_price VALUES ('2023-05-24 12:00:00+03', 0.4);
INSERT INTO public.hourly_price VALUES ('2023-05-24 13:00:00+03', 0.18);
INSERT INTO public.hourly_price VALUES ('2023-05-24 14:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-24 15:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-05-24 16:00:00+03', -0.19);
INSERT INTO public.hourly_price VALUES ('2023-05-24 17:00:00+03', -0.26);
INSERT INTO public.hourly_price VALUES ('2023-05-24 18:00:00+03', -0.26);
INSERT INTO public.hourly_price VALUES ('2023-05-24 19:00:00+03', -0.25);
INSERT INTO public.hourly_price VALUES ('2023-05-24 20:00:00+03', -0.19);
INSERT INTO public.hourly_price VALUES ('2023-05-24 21:00:00+03', -0.04);
INSERT INTO public.hourly_price VALUES ('2023-05-24 22:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-24 23:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-25 00:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-25 01:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-25 02:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-25 03:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-25 04:00:00+03', -0.31);
INSERT INTO public.hourly_price VALUES ('2023-05-25 05:00:00+03', -0.33);
INSERT INTO public.hourly_price VALUES ('2023-05-25 06:00:00+03', -0.33);
INSERT INTO public.hourly_price VALUES ('2023-05-25 07:00:00+03', -0.34);
INSERT INTO public.hourly_price VALUES ('2023-05-25 08:00:00+03', -0.33);
INSERT INTO public.hourly_price VALUES ('2023-05-25 09:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-25 10:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-25 11:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-05-25 12:00:00+03', 1.74);
INSERT INTO public.hourly_price VALUES ('2023-05-25 13:00:00+03', 1.19);
INSERT INTO public.hourly_price VALUES ('2023-05-25 14:00:00+03', 0.44);
INSERT INTO public.hourly_price VALUES ('2023-05-25 15:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-25 16:00:00+03', -0.08);
INSERT INTO public.hourly_price VALUES ('2023-05-25 17:00:00+03', -0.19);
INSERT INTO public.hourly_price VALUES ('2023-05-25 18:00:00+03', -0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-25 19:00:00+03', -0.25);
INSERT INTO public.hourly_price VALUES ('2023-05-25 20:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-25 21:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-05-25 22:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-05-25 23:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-26 00:00:00+03', 0.18);
INSERT INTO public.hourly_price VALUES ('2023-05-26 01:00:00+03', 0.23);
INSERT INTO public.hourly_price VALUES ('2023-05-26 02:00:00+03', 0.17);
INSERT INTO public.hourly_price VALUES ('2023-05-26 03:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-26 04:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-26 05:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-26 06:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-26 07:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-26 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-26 09:00:00+03', 0.17);
INSERT INTO public.hourly_price VALUES ('2023-05-26 10:00:00+03', 0.27);
INSERT INTO public.hourly_price VALUES ('2023-05-26 11:00:00+03', 4.98);
INSERT INTO public.hourly_price VALUES ('2023-05-26 12:00:00+03', 6.51);
INSERT INTO public.hourly_price VALUES ('2023-05-26 13:00:00+03', 3.56);
INSERT INTO public.hourly_price VALUES ('2023-05-26 14:00:00+03', 1.82);
INSERT INTO public.hourly_price VALUES ('2023-05-26 15:00:00+03', 0.49);
INSERT INTO public.hourly_price VALUES ('2023-05-26 16:00:00+03', 0.26);
INSERT INTO public.hourly_price VALUES ('2023-05-26 17:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-05-26 18:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-26 19:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-26 20:00:00+03', 0.17);
INSERT INTO public.hourly_price VALUES ('2023-05-26 21:00:00+03', 0.22);
INSERT INTO public.hourly_price VALUES ('2023-05-26 22:00:00+03', 0.3);
INSERT INTO public.hourly_price VALUES ('2023-05-26 23:00:00+03', 0.4);
INSERT INTO public.hourly_price VALUES ('2023-05-27 00:00:00+03', 0.43);
INSERT INTO public.hourly_price VALUES ('2023-05-27 01:00:00+03', 0.49);
INSERT INTO public.hourly_price VALUES ('2023-05-27 02:00:00+03', 0.43);
INSERT INTO public.hourly_price VALUES ('2023-05-27 03:00:00+03', 0.27);
INSERT INTO public.hourly_price VALUES ('2023-05-27 04:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-27 05:00:00+03', 0.23);
INSERT INTO public.hourly_price VALUES ('2023-05-27 06:00:00+03', 0.3);
INSERT INTO public.hourly_price VALUES ('2023-05-27 07:00:00+03', 0.38);
INSERT INTO public.hourly_price VALUES ('2023-05-27 08:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-05-27 09:00:00+03', 0.82);
INSERT INTO public.hourly_price VALUES ('2023-05-27 10:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-05-27 11:00:00+03', 2.19);
INSERT INTO public.hourly_price VALUES ('2023-05-27 12:00:00+03', 3.83);
INSERT INTO public.hourly_price VALUES ('2023-05-27 13:00:00+03', 1.63);
INSERT INTO public.hourly_price VALUES ('2023-05-27 14:00:00+03', 0.96);
INSERT INTO public.hourly_price VALUES ('2023-05-27 15:00:00+03', 0.18);
INSERT INTO public.hourly_price VALUES ('2023-05-27 16:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-27 17:00:00+03', -0.23);
INSERT INTO public.hourly_price VALUES ('2023-05-27 18:00:00+03', -0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-27 19:00:00+03', 0.05);
INSERT INTO public.hourly_price VALUES ('2023-05-27 20:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-27 21:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-27 22:00:00+03', 0.23);
INSERT INTO public.hourly_price VALUES ('2023-05-27 23:00:00+03', 0.17);
INSERT INTO public.hourly_price VALUES ('2023-05-28 00:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-05-28 01:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-28 02:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-28 03:00:00+03', -0.35);
INSERT INTO public.hourly_price VALUES ('2023-05-28 04:00:00+03', -0.34);
INSERT INTO public.hourly_price VALUES ('2023-05-28 05:00:00+03', -0.36);
INSERT INTO public.hourly_price VALUES ('2023-05-28 06:00:00+03', -0.41);
INSERT INTO public.hourly_price VALUES ('2023-05-28 07:00:00+03', -0.39);
INSERT INTO public.hourly_price VALUES ('2023-05-28 08:00:00+03', -0.45);
INSERT INTO public.hourly_price VALUES ('2023-05-28 09:00:00+03', -0.5);
INSERT INTO public.hourly_price VALUES ('2023-05-28 10:00:00+03', -0.44);
INSERT INTO public.hourly_price VALUES ('2023-05-28 11:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-28 12:00:00+03', -0.1);
INSERT INTO public.hourly_price VALUES ('2023-05-28 13:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-28 14:00:00+03', -0.31);
INSERT INTO public.hourly_price VALUES ('2023-05-28 15:00:00+03', -1.01);
INSERT INTO public.hourly_price VALUES ('2023-05-28 16:00:00+03', -1);
INSERT INTO public.hourly_price VALUES ('2023-05-28 17:00:00+03', -0.99);
INSERT INTO public.hourly_price VALUES ('2023-05-28 18:00:00+03', -1);
INSERT INTO public.hourly_price VALUES ('2023-05-28 19:00:00+03', -0.49);
INSERT INTO public.hourly_price VALUES ('2023-05-28 20:00:00+03', -0.5);
INSERT INTO public.hourly_price VALUES ('2023-05-28 21:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-28 22:00:00+03', 0.39);
INSERT INTO public.hourly_price VALUES ('2023-05-28 23:00:00+03', 0.25);
INSERT INTO public.hourly_price VALUES ('2023-05-29 00:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-29 01:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-05-29 02:00:00+03', 0.16);
INSERT INTO public.hourly_price VALUES ('2023-05-29 03:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-29 04:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-29 05:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-29 06:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-29 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-29 08:00:00+03', 0.14);
INSERT INTO public.hourly_price VALUES ('2023-05-29 09:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-05-29 10:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-05-29 11:00:00+03', 3.36);
INSERT INTO public.hourly_price VALUES ('2023-05-29 12:00:00+03', 3.71);
INSERT INTO public.hourly_price VALUES ('2023-05-29 13:00:00+03', 0.5);
INSERT INTO public.hourly_price VALUES ('2023-05-29 14:00:00+03', 0.43);
INSERT INTO public.hourly_price VALUES ('2023-05-29 15:00:00+03', 0.29);
INSERT INTO public.hourly_price VALUES ('2023-05-29 16:00:00+03', 0.26);
INSERT INTO public.hourly_price VALUES ('2023-05-29 17:00:00+03', 0.23);
INSERT INTO public.hourly_price VALUES ('2023-05-29 18:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-05-29 19:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-29 20:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-05-29 21:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-05-29 22:00:00+03', 0.99);
INSERT INTO public.hourly_price VALUES ('2023-05-29 23:00:00+03', 1.16);
INSERT INTO public.hourly_price VALUES ('2023-05-30 00:00:00+03', 1.22);
INSERT INTO public.hourly_price VALUES ('2023-05-30 01:00:00+03', 1.14);
INSERT INTO public.hourly_price VALUES ('2023-05-30 02:00:00+03', 0.99);
INSERT INTO public.hourly_price VALUES ('2023-05-30 03:00:00+03', 0.37);
INSERT INTO public.hourly_price VALUES ('2023-05-30 04:00:00+03', 1.06);
INSERT INTO public.hourly_price VALUES ('2023-05-30 05:00:00+03', 1);
INSERT INTO public.hourly_price VALUES ('2023-05-30 06:00:00+03', 1.12);
INSERT INTO public.hourly_price VALUES ('2023-05-30 07:00:00+03', 1.04);
INSERT INTO public.hourly_price VALUES ('2023-05-30 08:00:00+03', 1.45);
INSERT INTO public.hourly_price VALUES ('2023-05-30 09:00:00+03', 6.33);
INSERT INTO public.hourly_price VALUES ('2023-05-30 10:00:00+03', 8.91);
INSERT INTO public.hourly_price VALUES ('2023-05-30 11:00:00+03', 14.63);
INSERT INTO public.hourly_price VALUES ('2023-05-30 12:00:00+03', 13.47);
INSERT INTO public.hourly_price VALUES ('2023-05-30 13:00:00+03', 11.17);
INSERT INTO public.hourly_price VALUES ('2023-05-30 14:00:00+03', 10.21);
INSERT INTO public.hourly_price VALUES ('2023-05-30 15:00:00+03', 8.71);
INSERT INTO public.hourly_price VALUES ('2023-05-30 16:00:00+03', 8);
INSERT INTO public.hourly_price VALUES ('2023-05-30 17:00:00+03', 7.11);
INSERT INTO public.hourly_price VALUES ('2023-05-30 18:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-05-30 19:00:00+03', 1.62);
INSERT INTO public.hourly_price VALUES ('2023-05-30 20:00:00+03', 1.48);
INSERT INTO public.hourly_price VALUES ('2023-05-30 21:00:00+03', 1.18);
INSERT INTO public.hourly_price VALUES ('2023-05-30 22:00:00+03', 1.22);
INSERT INTO public.hourly_price VALUES ('2023-05-30 23:00:00+03', 0.74);
INSERT INTO public.hourly_price VALUES ('2023-05-31 00:00:00+03', 0.31);
INSERT INTO public.hourly_price VALUES ('2023-05-31 01:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-05-31 02:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-31 03:00:00+03', -0.13);
INSERT INTO public.hourly_price VALUES ('2023-05-31 04:00:00+03', -0.37);
INSERT INTO public.hourly_price VALUES ('2023-05-31 05:00:00+03', -0.38);
INSERT INTO public.hourly_price VALUES ('2023-05-31 06:00:00+03', -0.38);
INSERT INTO public.hourly_price VALUES ('2023-05-31 07:00:00+03', -0.41);
INSERT INTO public.hourly_price VALUES ('2023-05-31 08:00:00+03', -0.33);
INSERT INTO public.hourly_price VALUES ('2023-05-31 09:00:00+03', -0.26);
INSERT INTO public.hourly_price VALUES ('2023-05-31 10:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-31 11:00:00+03', 0.04);
INSERT INTO public.hourly_price VALUES ('2023-05-31 12:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-05-31 13:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-05-31 14:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-05-31 15:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-31 16:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-05-31 17:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-31 18:00:00+03', -0.08);
INSERT INTO public.hourly_price VALUES ('2023-05-31 19:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-05-31 20:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-31 21:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-31 22:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-05-31 23:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-01 00:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-01 01:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-01 02:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-01 03:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-01 04:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-01 05:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-01 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-01 07:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-01 08:00:00+03', 0.17);
INSERT INTO public.hourly_price VALUES ('2023-06-01 09:00:00+03', 0.26);
INSERT INTO public.hourly_price VALUES ('2023-06-01 10:00:00+03', 0.49);
INSERT INTO public.hourly_price VALUES ('2023-06-01 11:00:00+03', 0.92);
INSERT INTO public.hourly_price VALUES ('2023-06-01 12:00:00+03', 1.57);
INSERT INTO public.hourly_price VALUES ('2023-06-01 13:00:00+03', 1.07);
INSERT INTO public.hourly_price VALUES ('2023-06-01 14:00:00+03', 0.98);
INSERT INTO public.hourly_price VALUES ('2023-06-01 15:00:00+03', 0.82);
INSERT INTO public.hourly_price VALUES ('2023-06-01 16:00:00+03', 0.63);
INSERT INTO public.hourly_price VALUES ('2023-06-01 17:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-06-01 18:00:00+03', 0.37);
INSERT INTO public.hourly_price VALUES ('2023-06-01 19:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-01 20:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-01 21:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-01 22:00:00+03', 0.73);
INSERT INTO public.hourly_price VALUES ('2023-06-01 23:00:00+03', 0.86);
INSERT INTO public.hourly_price VALUES ('2023-06-02 00:00:00+03', 0.98);
INSERT INTO public.hourly_price VALUES ('2023-06-02 01:00:00+03', 1.17);
INSERT INTO public.hourly_price VALUES ('2023-06-02 02:00:00+03', 1.08);
INSERT INTO public.hourly_price VALUES ('2023-06-02 03:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-02 04:00:00+03', 0.25);
INSERT INTO public.hourly_price VALUES ('2023-06-02 05:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-06-02 06:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-06-02 07:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-06-02 08:00:00+03', 0.26);
INSERT INTO public.hourly_price VALUES ('2023-06-02 09:00:00+03', 0.46);
INSERT INTO public.hourly_price VALUES ('2023-06-02 10:00:00+03', 1.09);
INSERT INTO public.hourly_price VALUES ('2023-06-02 11:00:00+03', 1.29);
INSERT INTO public.hourly_price VALUES ('2023-06-02 12:00:00+03', 2.05);
INSERT INTO public.hourly_price VALUES ('2023-06-02 13:00:00+03', 2.15);
INSERT INTO public.hourly_price VALUES ('2023-06-02 14:00:00+03', 2.17);
INSERT INTO public.hourly_price VALUES ('2023-06-02 15:00:00+03', 2.18);
INSERT INTO public.hourly_price VALUES ('2023-06-02 16:00:00+03', 2.17);
INSERT INTO public.hourly_price VALUES ('2023-06-02 17:00:00+03', 2.19);
INSERT INTO public.hourly_price VALUES ('2023-06-02 18:00:00+03', 2.22);
INSERT INTO public.hourly_price VALUES ('2023-06-02 19:00:00+03', 2.38);
INSERT INTO public.hourly_price VALUES ('2023-06-02 20:00:00+03', 3.52);
INSERT INTO public.hourly_price VALUES ('2023-06-02 21:00:00+03', 4.97);
INSERT INTO public.hourly_price VALUES ('2023-06-02 22:00:00+03', 6.82);
INSERT INTO public.hourly_price VALUES ('2023-06-02 23:00:00+03', 7.06);
INSERT INTO public.hourly_price VALUES ('2023-06-03 00:00:00+03', 6.97);
INSERT INTO public.hourly_price VALUES ('2023-06-03 01:00:00+03', 6.87);
INSERT INTO public.hourly_price VALUES ('2023-06-03 02:00:00+03', 6.64);
INSERT INTO public.hourly_price VALUES ('2023-06-03 03:00:00+03', 4.38);
INSERT INTO public.hourly_price VALUES ('2023-06-03 04:00:00+03', 3.98);
INSERT INTO public.hourly_price VALUES ('2023-06-03 05:00:00+03', 3.12);
INSERT INTO public.hourly_price VALUES ('2023-06-03 06:00:00+03', 2.66);
INSERT INTO public.hourly_price VALUES ('2023-06-03 07:00:00+03', 2.31);
INSERT INTO public.hourly_price VALUES ('2023-06-03 08:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-06-03 09:00:00+03', 2.41);
INSERT INTO public.hourly_price VALUES ('2023-06-03 10:00:00+03', 2.88);
INSERT INTO public.hourly_price VALUES ('2023-06-03 11:00:00+03', 4.28);
INSERT INTO public.hourly_price VALUES ('2023-06-03 12:00:00+03', 4.62);
INSERT INTO public.hourly_price VALUES ('2023-06-03 13:00:00+03', 3.95);
INSERT INTO public.hourly_price VALUES ('2023-06-03 14:00:00+03', 2.77);
INSERT INTO public.hourly_price VALUES ('2023-06-03 15:00:00+03', 0.77);
INSERT INTO public.hourly_price VALUES ('2023-06-03 16:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-06-03 17:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-06-03 18:00:00+03', 0.22);
INSERT INTO public.hourly_price VALUES ('2023-06-03 19:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-06-03 20:00:00+03', 0.67);
INSERT INTO public.hourly_price VALUES ('2023-06-03 21:00:00+03', 1.73);
INSERT INTO public.hourly_price VALUES ('2023-06-03 22:00:00+03', 2.44);
INSERT INTO public.hourly_price VALUES ('2023-06-03 23:00:00+03', 2);
INSERT INTO public.hourly_price VALUES ('2023-06-04 00:00:00+03', 1.62);
INSERT INTO public.hourly_price VALUES ('2023-06-04 01:00:00+03', 1.43);
INSERT INTO public.hourly_price VALUES ('2023-06-04 02:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-06-04 03:00:00+03', 1.1);
INSERT INTO public.hourly_price VALUES ('2023-06-04 04:00:00+03', 0.89);
INSERT INTO public.hourly_price VALUES ('2023-06-04 05:00:00+03', 0.9);
INSERT INTO public.hourly_price VALUES ('2023-06-04 06:00:00+03', 0.91);
INSERT INTO public.hourly_price VALUES ('2023-06-04 07:00:00+03', 0.91);
INSERT INTO public.hourly_price VALUES ('2023-06-04 08:00:00+03', 1.01);
INSERT INTO public.hourly_price VALUES ('2023-06-04 09:00:00+03', 1.14);
INSERT INTO public.hourly_price VALUES ('2023-06-04 10:00:00+03', 1.26);
INSERT INTO public.hourly_price VALUES ('2023-06-04 11:00:00+03', 1.49);
INSERT INTO public.hourly_price VALUES ('2023-06-04 12:00:00+03', 1.72);
INSERT INTO public.hourly_price VALUES ('2023-06-04 13:00:00+03', 2.14);
INSERT INTO public.hourly_price VALUES ('2023-06-04 14:00:00+03', 1.02);
INSERT INTO public.hourly_price VALUES ('2023-06-04 15:00:00+03', 0.56);
INSERT INTO public.hourly_price VALUES ('2023-06-04 16:00:00+03', 0.5);
INSERT INTO public.hourly_price VALUES ('2023-06-04 17:00:00+03', 0.45);
INSERT INTO public.hourly_price VALUES ('2023-06-04 18:00:00+03', 0.38);
INSERT INTO public.hourly_price VALUES ('2023-06-04 19:00:00+03', 0.37);
INSERT INTO public.hourly_price VALUES ('2023-06-04 20:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-04 21:00:00+03', 1.91);
INSERT INTO public.hourly_price VALUES ('2023-06-04 22:00:00+03', 1.92);
INSERT INTO public.hourly_price VALUES ('2023-06-04 23:00:00+03', 1.97);
INSERT INTO public.hourly_price VALUES ('2023-06-05 00:00:00+03', 1.63);
INSERT INTO public.hourly_price VALUES ('2023-06-05 01:00:00+03', 1.54);
INSERT INTO public.hourly_price VALUES ('2023-06-05 02:00:00+03', 1.18);
INSERT INTO public.hourly_price VALUES ('2023-06-05 03:00:00+03', 0.81);
INSERT INTO public.hourly_price VALUES ('2023-06-05 04:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-06-05 05:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-05 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-05 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-05 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-05 09:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-05 10:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-06-05 11:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-06-05 12:00:00+03', 0.83);
INSERT INTO public.hourly_price VALUES ('2023-06-05 13:00:00+03', 0.8);
INSERT INTO public.hourly_price VALUES ('2023-06-05 14:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-05 15:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-05 16:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-05 17:00:00+03', 0.63);
INSERT INTO public.hourly_price VALUES ('2023-06-05 18:00:00+03', 0.63);
INSERT INTO public.hourly_price VALUES ('2023-06-05 19:00:00+03', 0.67);
INSERT INTO public.hourly_price VALUES ('2023-06-05 20:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-06-05 21:00:00+03', 0.67);
INSERT INTO public.hourly_price VALUES ('2023-06-05 22:00:00+03', 0.77);
INSERT INTO public.hourly_price VALUES ('2023-06-05 23:00:00+03', 0.95);
INSERT INTO public.hourly_price VALUES ('2023-06-06 00:00:00+03', 1);
INSERT INTO public.hourly_price VALUES ('2023-06-06 01:00:00+03', 0.99);
INSERT INTO public.hourly_price VALUES ('2023-06-06 02:00:00+03', 0.52);
INSERT INTO public.hourly_price VALUES ('2023-06-06 03:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-06 04:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-06 05:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-06 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-06 07:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-06-06 08:00:00+03', 1.21);
INSERT INTO public.hourly_price VALUES ('2023-06-06 09:00:00+03', 1.78);
INSERT INTO public.hourly_price VALUES ('2023-06-06 10:00:00+03', 2.26);
INSERT INTO public.hourly_price VALUES ('2023-06-06 11:00:00+03', 2.74);
INSERT INTO public.hourly_price VALUES ('2023-06-06 12:00:00+03', 3.31);
INSERT INTO public.hourly_price VALUES ('2023-06-06 13:00:00+03', 3.34);
INSERT INTO public.hourly_price VALUES ('2023-06-06 14:00:00+03', 3.08);
INSERT INTO public.hourly_price VALUES ('2023-06-06 15:00:00+03', 2.69);
INSERT INTO public.hourly_price VALUES ('2023-06-06 16:00:00+03', 2.73);
INSERT INTO public.hourly_price VALUES ('2023-06-06 17:00:00+03', 2.39);
INSERT INTO public.hourly_price VALUES ('2023-06-06 18:00:00+03', 2.39);
INSERT INTO public.hourly_price VALUES ('2023-06-06 19:00:00+03', 2.34);
INSERT INTO public.hourly_price VALUES ('2023-06-06 20:00:00+03', 2.4);
INSERT INTO public.hourly_price VALUES ('2023-06-06 21:00:00+03', 2.7);
INSERT INTO public.hourly_price VALUES ('2023-06-06 22:00:00+03', 3.09);
INSERT INTO public.hourly_price VALUES ('2023-06-06 23:00:00+03', 3.15);
INSERT INTO public.hourly_price VALUES ('2023-06-07 00:00:00+03', 2.72);
INSERT INTO public.hourly_price VALUES ('2023-06-07 01:00:00+03', 2.55);
INSERT INTO public.hourly_price VALUES ('2023-06-07 02:00:00+03', 2.38);
INSERT INTO public.hourly_price VALUES ('2023-06-07 03:00:00+03', 2.27);
INSERT INTO public.hourly_price VALUES ('2023-06-07 04:00:00+03', 2.83);
INSERT INTO public.hourly_price VALUES ('2023-06-07 05:00:00+03', 2.71);
INSERT INTO public.hourly_price VALUES ('2023-06-07 06:00:00+03', 2.61);
INSERT INTO public.hourly_price VALUES ('2023-06-07 07:00:00+03', 2.67);
INSERT INTO public.hourly_price VALUES ('2023-06-07 08:00:00+03', 2.79);
INSERT INTO public.hourly_price VALUES ('2023-06-07 09:00:00+03', 3.28);
INSERT INTO public.hourly_price VALUES ('2023-06-07 10:00:00+03', 4.22);
INSERT INTO public.hourly_price VALUES ('2023-06-07 11:00:00+03', 5.07);
INSERT INTO public.hourly_price VALUES ('2023-06-07 12:00:00+03', 6.03);
INSERT INTO public.hourly_price VALUES ('2023-06-07 13:00:00+03', 5.07);
INSERT INTO public.hourly_price VALUES ('2023-06-07 14:00:00+03', 4.57);
INSERT INTO public.hourly_price VALUES ('2023-06-07 15:00:00+03', 4.29);
INSERT INTO public.hourly_price VALUES ('2023-06-07 16:00:00+03', 3.72);
INSERT INTO public.hourly_price VALUES ('2023-06-07 17:00:00+03', 3.43);
INSERT INTO public.hourly_price VALUES ('2023-06-07 18:00:00+03', 3.28);
INSERT INTO public.hourly_price VALUES ('2023-06-07 19:00:00+03', 3.18);
INSERT INTO public.hourly_price VALUES ('2023-06-07 20:00:00+03', 3.23);
INSERT INTO public.hourly_price VALUES ('2023-06-07 21:00:00+03', 3.26);
INSERT INTO public.hourly_price VALUES ('2023-06-07 22:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-06-07 23:00:00+03', 3.34);
INSERT INTO public.hourly_price VALUES ('2023-06-08 00:00:00+03', 3.09);
INSERT INTO public.hourly_price VALUES ('2023-06-08 01:00:00+03', 2.74);
INSERT INTO public.hourly_price VALUES ('2023-06-08 02:00:00+03', 2.4);
INSERT INTO public.hourly_price VALUES ('2023-06-08 03:00:00+03', 2.04);
INSERT INTO public.hourly_price VALUES ('2023-06-08 04:00:00+03', 2.41);
INSERT INTO public.hourly_price VALUES ('2023-06-08 05:00:00+03', 2.42);
INSERT INTO public.hourly_price VALUES ('2023-06-08 06:00:00+03', 2.41);
INSERT INTO public.hourly_price VALUES ('2023-06-08 07:00:00+03', 2.39);
INSERT INTO public.hourly_price VALUES ('2023-06-08 08:00:00+03', 2.41);
INSERT INTO public.hourly_price VALUES ('2023-06-08 09:00:00+03', 2.46);
INSERT INTO public.hourly_price VALUES ('2023-06-08 10:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-06-08 11:00:00+03', 3.49);
INSERT INTO public.hourly_price VALUES ('2023-06-08 12:00:00+03', 3.66);
INSERT INTO public.hourly_price VALUES ('2023-06-08 13:00:00+03', 3.45);
INSERT INTO public.hourly_price VALUES ('2023-06-08 14:00:00+03', 3.4);
INSERT INTO public.hourly_price VALUES ('2023-06-08 15:00:00+03', 3.27);
INSERT INTO public.hourly_price VALUES ('2023-06-08 16:00:00+03', 3.3);
INSERT INTO public.hourly_price VALUES ('2023-06-08 17:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-06-08 18:00:00+03', 3.13);
INSERT INTO public.hourly_price VALUES ('2023-06-08 19:00:00+03', 3.13);
INSERT INTO public.hourly_price VALUES ('2023-06-08 20:00:00+03', 3.13);
INSERT INTO public.hourly_price VALUES ('2023-06-08 21:00:00+03', 3.19);
INSERT INTO public.hourly_price VALUES ('2023-06-08 22:00:00+03', 3.31);
INSERT INTO public.hourly_price VALUES ('2023-06-08 23:00:00+03', 3.34);
INSERT INTO public.hourly_price VALUES ('2023-06-09 00:00:00+03', 3.28);
INSERT INTO public.hourly_price VALUES ('2023-06-09 01:00:00+03', 3.24);
INSERT INTO public.hourly_price VALUES ('2023-06-09 02:00:00+03', 2.97);
INSERT INTO public.hourly_price VALUES ('2023-06-09 03:00:00+03', 1.88);
INSERT INTO public.hourly_price VALUES ('2023-06-09 04:00:00+03', 0.05);
INSERT INTO public.hourly_price VALUES ('2023-06-09 05:00:00+03', 0.1);
INSERT INTO public.hourly_price VALUES ('2023-06-09 06:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-06-09 07:00:00+03', 1.42);
INSERT INTO public.hourly_price VALUES ('2023-06-09 08:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-06-09 09:00:00+03', 3.99);
INSERT INTO public.hourly_price VALUES ('2023-06-09 10:00:00+03', 4.92);
INSERT INTO public.hourly_price VALUES ('2023-06-09 11:00:00+03', 5.37);
INSERT INTO public.hourly_price VALUES ('2023-06-09 12:00:00+03', 5.53);
INSERT INTO public.hourly_price VALUES ('2023-06-09 13:00:00+03', 5.26);
INSERT INTO public.hourly_price VALUES ('2023-06-09 14:00:00+03', 5.14);
INSERT INTO public.hourly_price VALUES ('2023-06-09 15:00:00+03', 5.02);
INSERT INTO public.hourly_price VALUES ('2023-06-09 16:00:00+03', 4.82);
INSERT INTO public.hourly_price VALUES ('2023-06-09 17:00:00+03', 4.2);
INSERT INTO public.hourly_price VALUES ('2023-06-09 18:00:00+03', 3.93);
INSERT INTO public.hourly_price VALUES ('2023-06-09 19:00:00+03', 3.96);
INSERT INTO public.hourly_price VALUES ('2023-06-09 20:00:00+03', 4.28);
INSERT INTO public.hourly_price VALUES ('2023-06-09 21:00:00+03', 4.85);
INSERT INTO public.hourly_price VALUES ('2023-06-09 22:00:00+03', 5.12);
INSERT INTO public.hourly_price VALUES ('2023-06-09 23:00:00+03', 5.16);
INSERT INTO public.hourly_price VALUES ('2023-06-10 00:00:00+03', 4.84);
INSERT INTO public.hourly_price VALUES ('2023-06-10 01:00:00+03', 4.16);
INSERT INTO public.hourly_price VALUES ('2023-06-10 02:00:00+03', 3.68);
INSERT INTO public.hourly_price VALUES ('2023-06-10 03:00:00+03', 3.05);
INSERT INTO public.hourly_price VALUES ('2023-06-10 04:00:00+03', 2.57);
INSERT INTO public.hourly_price VALUES ('2023-06-10 05:00:00+03', 2.52);
INSERT INTO public.hourly_price VALUES ('2023-06-10 06:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-06-10 07:00:00+03', 2.49);
INSERT INTO public.hourly_price VALUES ('2023-06-10 08:00:00+03', 2.53);
INSERT INTO public.hourly_price VALUES ('2023-06-10 09:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-06-10 10:00:00+03', 3.31);
INSERT INTO public.hourly_price VALUES ('2023-06-10 11:00:00+03', 4.48);
INSERT INTO public.hourly_price VALUES ('2023-06-10 12:00:00+03', 4.95);
INSERT INTO public.hourly_price VALUES ('2023-06-10 13:00:00+03', 4.9);
INSERT INTO public.hourly_price VALUES ('2023-06-10 14:00:00+03', 3.18);
INSERT INTO public.hourly_price VALUES ('2023-06-10 15:00:00+03', 1.6);
INSERT INTO public.hourly_price VALUES ('2023-06-10 16:00:00+03', 0.57);
INSERT INTO public.hourly_price VALUES ('2023-06-10 17:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-06-10 18:00:00+03', 1.06);
INSERT INTO public.hourly_price VALUES ('2023-06-10 19:00:00+03', 1.28);
INSERT INTO public.hourly_price VALUES ('2023-06-10 20:00:00+03', 1.69);
INSERT INTO public.hourly_price VALUES ('2023-06-10 21:00:00+03', 4.14);
INSERT INTO public.hourly_price VALUES ('2023-06-10 22:00:00+03', 5.26);
INSERT INTO public.hourly_price VALUES ('2023-06-10 23:00:00+03', 5.31);
INSERT INTO public.hourly_price VALUES ('2023-06-11 00:00:00+03', 5.15);
INSERT INTO public.hourly_price VALUES ('2023-06-11 01:00:00+03', 4.34);
INSERT INTO public.hourly_price VALUES ('2023-06-11 02:00:00+03', 2.98);
INSERT INTO public.hourly_price VALUES ('2023-06-11 03:00:00+03', 2.17);
INSERT INTO public.hourly_price VALUES ('2023-06-11 04:00:00+03', 1.36);
INSERT INTO public.hourly_price VALUES ('2023-06-11 05:00:00+03', 0.05);
INSERT INTO public.hourly_price VALUES ('2023-06-11 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-11 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-11 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-11 09:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-11 10:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-11 11:00:00+03', 2.54);
INSERT INTO public.hourly_price VALUES ('2023-06-11 12:00:00+03', 3.53);
INSERT INTO public.hourly_price VALUES ('2023-06-11 13:00:00+03', 1.97);
INSERT INTO public.hourly_price VALUES ('2023-06-11 14:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-11 15:00:00+03', -0.17);
INSERT INTO public.hourly_price VALUES ('2023-06-11 16:00:00+03', -0.35);
INSERT INTO public.hourly_price VALUES ('2023-06-11 17:00:00+03', -0.51);
INSERT INTO public.hourly_price VALUES ('2023-06-11 18:00:00+03', -0.51);
INSERT INTO public.hourly_price VALUES ('2023-06-11 19:00:00+03', -0.52);
INSERT INTO public.hourly_price VALUES ('2023-06-11 20:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-11 21:00:00+03', 0.27);
INSERT INTO public.hourly_price VALUES ('2023-06-11 22:00:00+03', 2.36);
INSERT INTO public.hourly_price VALUES ('2023-06-11 23:00:00+03', 0.56);
INSERT INTO public.hourly_price VALUES ('2023-06-12 00:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-12 01:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-12 02:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-12 03:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-12 04:00:00+03', -0.51);
INSERT INTO public.hourly_price VALUES ('2023-06-12 05:00:00+03', -1.1);
INSERT INTO public.hourly_price VALUES ('2023-06-12 06:00:00+03', -1.6);
INSERT INTO public.hourly_price VALUES ('2023-06-12 07:00:00+03', -0.56);
INSERT INTO public.hourly_price VALUES ('2023-06-12 08:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-06-12 09:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-06-12 10:00:00+03', 5.11);
INSERT INTO public.hourly_price VALUES ('2023-06-12 11:00:00+03', 5.47);
INSERT INTO public.hourly_price VALUES ('2023-06-12 12:00:00+03', 5.77);
INSERT INTO public.hourly_price VALUES ('2023-06-12 13:00:00+03', 5.57);
INSERT INTO public.hourly_price VALUES ('2023-06-12 14:00:00+03', 5.26);
INSERT INTO public.hourly_price VALUES ('2023-06-12 15:00:00+03', 5.01);
INSERT INTO public.hourly_price VALUES ('2023-06-12 16:00:00+03', 4.87);
INSERT INTO public.hourly_price VALUES ('2023-06-12 17:00:00+03', 4.44);
INSERT INTO public.hourly_price VALUES ('2023-06-12 18:00:00+03', 3.83);
INSERT INTO public.hourly_price VALUES ('2023-06-12 19:00:00+03', 3.17);
INSERT INTO public.hourly_price VALUES ('2023-06-12 20:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-06-12 21:00:00+03', 0.87);
INSERT INTO public.hourly_price VALUES ('2023-06-12 22:00:00+03', 3.44);
INSERT INTO public.hourly_price VALUES ('2023-06-12 23:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-06-13 00:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-13 01:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-06-13 02:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-06-13 03:00:00+03', -0.3);
INSERT INTO public.hourly_price VALUES ('2023-06-13 04:00:00+03', -1.13);
INSERT INTO public.hourly_price VALUES ('2023-06-13 05:00:00+03', -2.01);
INSERT INTO public.hourly_price VALUES ('2023-06-13 06:00:00+03', -3);
INSERT INTO public.hourly_price VALUES ('2023-06-13 07:00:00+03', -1.6);
INSERT INTO public.hourly_price VALUES ('2023-06-13 08:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-06-13 09:00:00+03', 2.29);
INSERT INTO public.hourly_price VALUES ('2023-06-13 10:00:00+03', 5.17);
INSERT INTO public.hourly_price VALUES ('2023-06-13 11:00:00+03', 6.85);
INSERT INTO public.hourly_price VALUES ('2023-06-13 12:00:00+03', 6.93);
INSERT INTO public.hourly_price VALUES ('2023-06-13 13:00:00+03', 6.96);
INSERT INTO public.hourly_price VALUES ('2023-06-13 14:00:00+03', 6.88);
INSERT INTO public.hourly_price VALUES ('2023-06-13 15:00:00+03', 6.72);
INSERT INTO public.hourly_price VALUES ('2023-06-13 16:00:00+03', 6.75);
INSERT INTO public.hourly_price VALUES ('2023-06-13 17:00:00+03', 6.22);
INSERT INTO public.hourly_price VALUES ('2023-06-13 18:00:00+03', 6.01);
INSERT INTO public.hourly_price VALUES ('2023-06-13 19:00:00+03', 6.86);
INSERT INTO public.hourly_price VALUES ('2023-06-13 20:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-06-13 21:00:00+03', 7.17);
INSERT INTO public.hourly_price VALUES ('2023-06-13 22:00:00+03', 7.1);
INSERT INTO public.hourly_price VALUES ('2023-06-13 23:00:00+03', 7.43);
INSERT INTO public.hourly_price VALUES ('2023-06-14 00:00:00+03', 7.43);
INSERT INTO public.hourly_price VALUES ('2023-06-14 01:00:00+03', 7.21);
INSERT INTO public.hourly_price VALUES ('2023-06-14 02:00:00+03', 7.02);
INSERT INTO public.hourly_price VALUES ('2023-06-14 03:00:00+03', 6.79);
INSERT INTO public.hourly_price VALUES ('2023-06-14 04:00:00+03', 6.99);
INSERT INTO public.hourly_price VALUES ('2023-06-14 05:00:00+03', 6.98);
INSERT INTO public.hourly_price VALUES ('2023-06-14 06:00:00+03', 6.98);
INSERT INTO public.hourly_price VALUES ('2023-06-14 07:00:00+03', 6.95);
INSERT INTO public.hourly_price VALUES ('2023-06-14 08:00:00+03', 7.08);
INSERT INTO public.hourly_price VALUES ('2023-06-14 09:00:00+03', 7.66);
INSERT INTO public.hourly_price VALUES ('2023-06-14 10:00:00+03', 8.12);
INSERT INTO public.hourly_price VALUES ('2023-06-14 11:00:00+03', 8.71);
INSERT INTO public.hourly_price VALUES ('2023-06-14 12:00:00+03', 9.15);
INSERT INTO public.hourly_price VALUES ('2023-06-14 13:00:00+03', 8.89);
INSERT INTO public.hourly_price VALUES ('2023-06-14 14:00:00+03', 8.69);
INSERT INTO public.hourly_price VALUES ('2023-06-14 15:00:00+03', 8.38);
INSERT INTO public.hourly_price VALUES ('2023-06-14 16:00:00+03', 8.67);
INSERT INTO public.hourly_price VALUES ('2023-06-14 17:00:00+03', 8.47);
INSERT INTO public.hourly_price VALUES ('2023-06-14 18:00:00+03', 8.49);
INSERT INTO public.hourly_price VALUES ('2023-06-14 19:00:00+03', 8.68);
INSERT INTO public.hourly_price VALUES ('2023-06-14 20:00:00+03', 8.85);
INSERT INTO public.hourly_price VALUES ('2023-06-14 21:00:00+03', 9.18);
INSERT INTO public.hourly_price VALUES ('2023-06-14 22:00:00+03', 8.96);
INSERT INTO public.hourly_price VALUES ('2023-06-14 23:00:00+03', 8.93);
INSERT INTO public.hourly_price VALUES ('2023-06-15 00:00:00+03', 8.68);
INSERT INTO public.hourly_price VALUES ('2023-06-15 01:00:00+03', 7.87);
INSERT INTO public.hourly_price VALUES ('2023-06-15 02:00:00+03', 7.15);
INSERT INTO public.hourly_price VALUES ('2023-06-15 03:00:00+03', 6.26);
INSERT INTO public.hourly_price VALUES ('2023-06-15 04:00:00+03', 6.53);
INSERT INTO public.hourly_price VALUES ('2023-06-15 05:00:00+03', 6.01);
INSERT INTO public.hourly_price VALUES ('2023-06-15 06:00:00+03', 5.99);
INSERT INTO public.hourly_price VALUES ('2023-06-15 07:00:00+03', 6.23);
INSERT INTO public.hourly_price VALUES ('2023-06-15 08:00:00+03', 6.43);
INSERT INTO public.hourly_price VALUES ('2023-06-15 09:00:00+03', 7.25);
INSERT INTO public.hourly_price VALUES ('2023-06-15 10:00:00+03', 7.53);
INSERT INTO public.hourly_price VALUES ('2023-06-15 11:00:00+03', 8.37);
INSERT INTO public.hourly_price VALUES ('2023-06-15 12:00:00+03', 8.96);
INSERT INTO public.hourly_price VALUES ('2023-06-15 13:00:00+03', 8.67);
INSERT INTO public.hourly_price VALUES ('2023-06-15 14:00:00+03', 8.5);
INSERT INTO public.hourly_price VALUES ('2023-06-15 15:00:00+03', 8.4);
INSERT INTO public.hourly_price VALUES ('2023-06-15 16:00:00+03', 8.44);
INSERT INTO public.hourly_price VALUES ('2023-06-15 17:00:00+03', 8.7);
INSERT INTO public.hourly_price VALUES ('2023-06-15 18:00:00+03', 8.67);
INSERT INTO public.hourly_price VALUES ('2023-06-15 19:00:00+03', 8.43);
INSERT INTO public.hourly_price VALUES ('2023-06-15 20:00:00+03', 8.31);
INSERT INTO public.hourly_price VALUES ('2023-06-15 21:00:00+03', 8.42);
INSERT INTO public.hourly_price VALUES ('2023-06-15 22:00:00+03', 8.67);
INSERT INTO public.hourly_price VALUES ('2023-06-15 23:00:00+03', 8.52);
INSERT INTO public.hourly_price VALUES ('2023-06-16 00:00:00+03', 7.89);
INSERT INTO public.hourly_price VALUES ('2023-06-16 01:00:00+03', 7.5);
INSERT INTO public.hourly_price VALUES ('2023-06-16 02:00:00+03', 7.05);
INSERT INTO public.hourly_price VALUES ('2023-06-16 03:00:00+03', 6.38);
INSERT INTO public.hourly_price VALUES ('2023-06-16 04:00:00+03', 7.81);
INSERT INTO public.hourly_price VALUES ('2023-06-16 05:00:00+03', 7.57);
INSERT INTO public.hourly_price VALUES ('2023-06-16 06:00:00+03', 7.44);
INSERT INTO public.hourly_price VALUES ('2023-06-16 07:00:00+03', 6.98);
INSERT INTO public.hourly_price VALUES ('2023-06-16 08:00:00+03', 7.56);
INSERT INTO public.hourly_price VALUES ('2023-06-16 09:00:00+03', 7.88);
INSERT INTO public.hourly_price VALUES ('2023-06-16 10:00:00+03', 7.61);
INSERT INTO public.hourly_price VALUES ('2023-06-16 11:00:00+03', 9.24);
INSERT INTO public.hourly_price VALUES ('2023-06-16 12:00:00+03', 10.74);
INSERT INTO public.hourly_price VALUES ('2023-06-16 13:00:00+03', 10.76);
INSERT INTO public.hourly_price VALUES ('2023-06-16 14:00:00+03', 9.67);
INSERT INTO public.hourly_price VALUES ('2023-06-16 15:00:00+03', 8.53);
INSERT INTO public.hourly_price VALUES ('2023-06-16 16:00:00+03', 8.3);
INSERT INTO public.hourly_price VALUES ('2023-06-16 17:00:00+03', 8.02);
INSERT INTO public.hourly_price VALUES ('2023-06-16 18:00:00+03', 7.76);
INSERT INTO public.hourly_price VALUES ('2023-06-16 19:00:00+03', 7.77);
INSERT INTO public.hourly_price VALUES ('2023-06-16 20:00:00+03', 7.95);
INSERT INTO public.hourly_price VALUES ('2023-06-16 21:00:00+03', 8.18);
INSERT INTO public.hourly_price VALUES ('2023-06-16 22:00:00+03', 8.26);
INSERT INTO public.hourly_price VALUES ('2023-06-16 23:00:00+03', 7.96);
INSERT INTO public.hourly_price VALUES ('2023-06-17 00:00:00+03', 7.4);
INSERT INTO public.hourly_price VALUES ('2023-06-17 01:00:00+03', 6.93);
INSERT INTO public.hourly_price VALUES ('2023-06-17 02:00:00+03', 6.35);
INSERT INTO public.hourly_price VALUES ('2023-06-17 03:00:00+03', 4.78);
INSERT INTO public.hourly_price VALUES ('2023-06-17 04:00:00+03', 5.9);
INSERT INTO public.hourly_price VALUES ('2023-06-17 05:00:00+03', 5.63);
INSERT INTO public.hourly_price VALUES ('2023-06-17 06:00:00+03', 5.85);
INSERT INTO public.hourly_price VALUES ('2023-06-17 07:00:00+03', 6.23);
INSERT INTO public.hourly_price VALUES ('2023-06-17 08:00:00+03', 6.26);
INSERT INTO public.hourly_price VALUES ('2023-06-17 09:00:00+03', 6.43);
INSERT INTO public.hourly_price VALUES ('2023-06-17 10:00:00+03', 6.59);
INSERT INTO public.hourly_price VALUES ('2023-06-17 11:00:00+03', 6.78);
INSERT INTO public.hourly_price VALUES ('2023-06-17 12:00:00+03', 6.9);
INSERT INTO public.hourly_price VALUES ('2023-06-17 13:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-06-17 14:00:00+03', 6.75);
INSERT INTO public.hourly_price VALUES ('2023-06-17 15:00:00+03', 6.67);
INSERT INTO public.hourly_price VALUES ('2023-06-17 16:00:00+03', 6.86);
INSERT INTO public.hourly_price VALUES ('2023-06-17 17:00:00+03', 6);
INSERT INTO public.hourly_price VALUES ('2023-06-17 18:00:00+03', 5);
INSERT INTO public.hourly_price VALUES ('2023-06-17 19:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-06-17 20:00:00+03', 6.9);
INSERT INTO public.hourly_price VALUES ('2023-06-17 21:00:00+03', 7.13);
INSERT INTO public.hourly_price VALUES ('2023-06-17 22:00:00+03', 7.3);
INSERT INTO public.hourly_price VALUES ('2023-06-17 23:00:00+03', 7.16);
INSERT INTO public.hourly_price VALUES ('2023-06-18 00:00:00+03', 6.76);
INSERT INTO public.hourly_price VALUES ('2023-06-18 01:00:00+03', 6.57);
INSERT INTO public.hourly_price VALUES ('2023-06-18 02:00:00+03', 6.31);
INSERT INTO public.hourly_price VALUES ('2023-06-18 03:00:00+03', 5.24);
INSERT INTO public.hourly_price VALUES ('2023-06-18 04:00:00+03', 4.63);
INSERT INTO public.hourly_price VALUES ('2023-06-18 05:00:00+03', 3.05);
INSERT INTO public.hourly_price VALUES ('2023-06-18 06:00:00+03', 3.03);
INSERT INTO public.hourly_price VALUES ('2023-06-18 07:00:00+03', 3.01);
INSERT INTO public.hourly_price VALUES ('2023-06-18 08:00:00+03', 3.34);
INSERT INTO public.hourly_price VALUES ('2023-06-18 09:00:00+03', 5.31);
INSERT INTO public.hourly_price VALUES ('2023-06-18 10:00:00+03', 5.89);
INSERT INTO public.hourly_price VALUES ('2023-06-18 11:00:00+03', 6.24);
INSERT INTO public.hourly_price VALUES ('2023-06-18 12:00:00+03', 6.55);
INSERT INTO public.hourly_price VALUES ('2023-06-18 13:00:00+03', 6.81);
INSERT INTO public.hourly_price VALUES ('2023-06-18 14:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-06-18 15:00:00+03', 6.49);
INSERT INTO public.hourly_price VALUES ('2023-06-18 16:00:00+03', 5.68);
INSERT INTO public.hourly_price VALUES ('2023-06-18 17:00:00+03', 3.73);
INSERT INTO public.hourly_price VALUES ('2023-06-18 18:00:00+03', 3.2);
INSERT INTO public.hourly_price VALUES ('2023-06-18 19:00:00+03', 6.07);
INSERT INTO public.hourly_price VALUES ('2023-06-18 20:00:00+03', 6.97);
INSERT INTO public.hourly_price VALUES ('2023-06-18 21:00:00+03', 6.97);
INSERT INTO public.hourly_price VALUES ('2023-06-18 22:00:00+03', 7.07);
INSERT INTO public.hourly_price VALUES ('2023-06-18 23:00:00+03', 7.05);
INSERT INTO public.hourly_price VALUES ('2023-06-19 00:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-06-19 01:00:00+03', 6.64);
INSERT INTO public.hourly_price VALUES ('2023-06-19 02:00:00+03', 6.36);
INSERT INTO public.hourly_price VALUES ('2023-06-19 03:00:00+03', 6.14);
INSERT INTO public.hourly_price VALUES ('2023-06-19 04:00:00+03', 6.12);
INSERT INTO public.hourly_price VALUES ('2023-06-19 05:00:00+03', 5.87);
INSERT INTO public.hourly_price VALUES ('2023-06-19 06:00:00+03', 5.97);
INSERT INTO public.hourly_price VALUES ('2023-06-19 07:00:00+03', 6.18);
INSERT INTO public.hourly_price VALUES ('2023-06-19 08:00:00+03', 6.6);
INSERT INTO public.hourly_price VALUES ('2023-06-19 09:00:00+03', 7.05);
INSERT INTO public.hourly_price VALUES ('2023-06-19 10:00:00+03', 9);
INSERT INTO public.hourly_price VALUES ('2023-06-19 11:00:00+03', 10.92);
INSERT INTO public.hourly_price VALUES ('2023-06-19 12:00:00+03', 15.92);
INSERT INTO public.hourly_price VALUES ('2023-06-19 13:00:00+03', 14.34);
INSERT INTO public.hourly_price VALUES ('2023-06-19 14:00:00+03', 11.94);
INSERT INTO public.hourly_price VALUES ('2023-06-19 15:00:00+03', 11.15);
INSERT INTO public.hourly_price VALUES ('2023-06-19 16:00:00+03', 10.86);
INSERT INTO public.hourly_price VALUES ('2023-06-19 17:00:00+03', 10.7);
INSERT INTO public.hourly_price VALUES ('2023-06-19 18:00:00+03', 10.59);
INSERT INTO public.hourly_price VALUES ('2023-06-19 19:00:00+03', 10.54);
INSERT INTO public.hourly_price VALUES ('2023-06-19 20:00:00+03', 10.46);
INSERT INTO public.hourly_price VALUES ('2023-06-19 21:00:00+03', 10.56);
INSERT INTO public.hourly_price VALUES ('2023-06-19 22:00:00+03', 10.55);
INSERT INTO public.hourly_price VALUES ('2023-06-19 23:00:00+03', 10.48);
INSERT INTO public.hourly_price VALUES ('2023-06-20 00:00:00+03', 10.42);
INSERT INTO public.hourly_price VALUES ('2023-06-20 01:00:00+03', 9.3);
INSERT INTO public.hourly_price VALUES ('2023-06-20 02:00:00+03', 7.75);
INSERT INTO public.hourly_price VALUES ('2023-06-20 03:00:00+03', 7.16);
INSERT INTO public.hourly_price VALUES ('2023-06-20 04:00:00+03', 7);
INSERT INTO public.hourly_price VALUES ('2023-06-20 05:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-06-20 06:00:00+03', 6.91);
INSERT INTO public.hourly_price VALUES ('2023-06-20 07:00:00+03', 6.86);
INSERT INTO public.hourly_price VALUES ('2023-06-20 08:00:00+03', 6.91);
INSERT INTO public.hourly_price VALUES ('2023-06-20 09:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-06-20 10:00:00+03', 7.3);
INSERT INTO public.hourly_price VALUES ('2023-06-20 11:00:00+03', 8.37);
INSERT INTO public.hourly_price VALUES ('2023-06-20 12:00:00+03', 9.74);
INSERT INTO public.hourly_price VALUES ('2023-06-20 13:00:00+03', 8.57);
INSERT INTO public.hourly_price VALUES ('2023-06-20 14:00:00+03', 8.07);
INSERT INTO public.hourly_price VALUES ('2023-06-20 15:00:00+03', 7.7);
INSERT INTO public.hourly_price VALUES ('2023-06-20 16:00:00+03', 7.88);
INSERT INTO public.hourly_price VALUES ('2023-06-20 17:00:00+03', 7.4);
INSERT INTO public.hourly_price VALUES ('2023-06-20 18:00:00+03', 7.3);
INSERT INTO public.hourly_price VALUES ('2023-06-20 19:00:00+03', 7.37);
INSERT INTO public.hourly_price VALUES ('2023-06-20 20:00:00+03', 7.64);
INSERT INTO public.hourly_price VALUES ('2023-06-20 21:00:00+03', 7.99);
INSERT INTO public.hourly_price VALUES ('2023-06-20 22:00:00+03', 8.51);
INSERT INTO public.hourly_price VALUES ('2023-06-20 23:00:00+03', 8.76);
INSERT INTO public.hourly_price VALUES ('2023-06-21 00:00:00+03', 7.77);
INSERT INTO public.hourly_price VALUES ('2023-06-21 01:00:00+03', 7.47);
INSERT INTO public.hourly_price VALUES ('2023-06-21 02:00:00+03', 7.1);
INSERT INTO public.hourly_price VALUES ('2023-06-21 03:00:00+03', 6.93);
INSERT INTO public.hourly_price VALUES ('2023-06-21 04:00:00+03', 6.95);
INSERT INTO public.hourly_price VALUES ('2023-06-21 05:00:00+03', 6.37);
INSERT INTO public.hourly_price VALUES ('2023-06-21 06:00:00+03', 5.95);
INSERT INTO public.hourly_price VALUES ('2023-06-21 07:00:00+03', 5.98);
INSERT INTO public.hourly_price VALUES ('2023-06-21 08:00:00+03', 6.64);
INSERT INTO public.hourly_price VALUES ('2023-06-21 09:00:00+03', 7.02);
INSERT INTO public.hourly_price VALUES ('2023-06-21 10:00:00+03', 7.27);
INSERT INTO public.hourly_price VALUES ('2023-06-21 11:00:00+03', 8.3);
INSERT INTO public.hourly_price VALUES ('2023-06-21 12:00:00+03', 9.59);
INSERT INTO public.hourly_price VALUES ('2023-06-21 13:00:00+03', 8.62);
INSERT INTO public.hourly_price VALUES ('2023-06-21 14:00:00+03', 7.88);
INSERT INTO public.hourly_price VALUES ('2023-06-21 15:00:00+03', 7.34);
INSERT INTO public.hourly_price VALUES ('2023-06-21 16:00:00+03', 7.35);
INSERT INTO public.hourly_price VALUES ('2023-06-21 17:00:00+03', 7.24);
INSERT INTO public.hourly_price VALUES ('2023-06-21 18:00:00+03', 7.22);
INSERT INTO public.hourly_price VALUES ('2023-06-21 19:00:00+03', 7.25);
INSERT INTO public.hourly_price VALUES ('2023-06-21 20:00:00+03', 7.27);
INSERT INTO public.hourly_price VALUES ('2023-06-21 21:00:00+03', 7.34);
INSERT INTO public.hourly_price VALUES ('2023-06-21 22:00:00+03', 7.38);
INSERT INTO public.hourly_price VALUES ('2023-06-21 23:00:00+03', 7.29);
INSERT INTO public.hourly_price VALUES ('2023-06-22 00:00:00+03', 7.06);
INSERT INTO public.hourly_price VALUES ('2023-06-22 01:00:00+03', 6.91);
INSERT INTO public.hourly_price VALUES ('2023-06-22 02:00:00+03', 6.32);
INSERT INTO public.hourly_price VALUES ('2023-06-22 03:00:00+03', 5.63);
INSERT INTO public.hourly_price VALUES ('2023-06-22 04:00:00+03', 5.93);
INSERT INTO public.hourly_price VALUES ('2023-06-22 05:00:00+03', 5.62);
INSERT INTO public.hourly_price VALUES ('2023-06-22 06:00:00+03', 5.14);
INSERT INTO public.hourly_price VALUES ('2023-06-22 07:00:00+03', 5.09);
INSERT INTO public.hourly_price VALUES ('2023-06-22 08:00:00+03', 5.62);
INSERT INTO public.hourly_price VALUES ('2023-06-22 09:00:00+03', 6.18);
INSERT INTO public.hourly_price VALUES ('2023-06-22 10:00:00+03', 6.27);
INSERT INTO public.hourly_price VALUES ('2023-06-22 11:00:00+03', 6.85);
INSERT INTO public.hourly_price VALUES ('2023-06-22 12:00:00+03', 7.38);
INSERT INTO public.hourly_price VALUES ('2023-06-22 13:00:00+03', 7.34);
INSERT INTO public.hourly_price VALUES ('2023-06-22 14:00:00+03', 6.56);
INSERT INTO public.hourly_price VALUES ('2023-06-22 15:00:00+03', 6.38);
INSERT INTO public.hourly_price VALUES ('2023-06-22 16:00:00+03', 6.21);
INSERT INTO public.hourly_price VALUES ('2023-06-22 17:00:00+03', 6.03);
INSERT INTO public.hourly_price VALUES ('2023-06-22 18:00:00+03', 5.95);
INSERT INTO public.hourly_price VALUES ('2023-06-22 19:00:00+03', 5.79);
INSERT INTO public.hourly_price VALUES ('2023-06-22 20:00:00+03', 5.22);
INSERT INTO public.hourly_price VALUES ('2023-06-22 21:00:00+03', 5.53);
INSERT INTO public.hourly_price VALUES ('2023-06-22 22:00:00+03', 5.98);
INSERT INTO public.hourly_price VALUES ('2023-06-22 23:00:00+03', 6.06);
INSERT INTO public.hourly_price VALUES ('2023-06-23 00:00:00+03', 6.06);
INSERT INTO public.hourly_price VALUES ('2023-06-23 01:00:00+03', 6.07);
INSERT INTO public.hourly_price VALUES ('2023-06-23 02:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-06-23 03:00:00+03', 2.76);
INSERT INTO public.hourly_price VALUES ('2023-06-23 04:00:00+03', 2.02);
INSERT INTO public.hourly_price VALUES ('2023-06-23 05:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-06-23 06:00:00+03', 0.46);
INSERT INTO public.hourly_price VALUES ('2023-06-23 07:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-06-23 08:00:00+03', 0.42);
INSERT INTO public.hourly_price VALUES ('2023-06-23 09:00:00+03', 1.29);
INSERT INTO public.hourly_price VALUES ('2023-06-23 10:00:00+03', 2.17);
INSERT INTO public.hourly_price VALUES ('2023-06-23 11:00:00+03', 3.91);
INSERT INTO public.hourly_price VALUES ('2023-06-23 12:00:00+03', 2.4);
INSERT INTO public.hourly_price VALUES ('2023-06-23 13:00:00+03', 2.16);
INSERT INTO public.hourly_price VALUES ('2023-06-23 14:00:00+03', 2.01);
INSERT INTO public.hourly_price VALUES ('2023-06-23 15:00:00+03', 1.27);
INSERT INTO public.hourly_price VALUES ('2023-06-23 16:00:00+03', 0.67);
INSERT INTO public.hourly_price VALUES ('2023-06-23 17:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-06-23 18:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-06-23 19:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-06-23 20:00:00+03', 0.42);
INSERT INTO public.hourly_price VALUES ('2023-06-23 21:00:00+03', 1.5);
INSERT INTO public.hourly_price VALUES ('2023-06-23 22:00:00+03', 2.11);
INSERT INTO public.hourly_price VALUES ('2023-06-23 23:00:00+03', 2.08);
INSERT INTO public.hourly_price VALUES ('2023-06-24 00:00:00+03', 2.02);
INSERT INTO public.hourly_price VALUES ('2023-06-24 01:00:00+03', 1.99);
INSERT INTO public.hourly_price VALUES ('2023-06-24 02:00:00+03', 1.85);
INSERT INTO public.hourly_price VALUES ('2023-06-24 03:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-06-24 04:00:00+03', 0.56);
INSERT INTO public.hourly_price VALUES ('2023-06-24 05:00:00+03', 0.37);
INSERT INTO public.hourly_price VALUES ('2023-06-24 06:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-06-24 07:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-06-24 08:00:00+03', 0.43);
INSERT INTO public.hourly_price VALUES ('2023-06-24 09:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-06-24 10:00:00+03', 2.06);
INSERT INTO public.hourly_price VALUES ('2023-06-24 11:00:00+03', 2.3);
INSERT INTO public.hourly_price VALUES ('2023-06-24 12:00:00+03', 2.51);
INSERT INTO public.hourly_price VALUES ('2023-06-24 13:00:00+03', 2.65);
INSERT INTO public.hourly_price VALUES ('2023-06-24 14:00:00+03', 2.71);
INSERT INTO public.hourly_price VALUES ('2023-06-24 15:00:00+03', 2.72);
INSERT INTO public.hourly_price VALUES ('2023-06-24 16:00:00+03', 1.86);
INSERT INTO public.hourly_price VALUES ('2023-06-24 17:00:00+03', 0.24);
INSERT INTO public.hourly_price VALUES ('2023-06-24 18:00:00+03', 0.04);
INSERT INTO public.hourly_price VALUES ('2023-06-24 19:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-06-24 20:00:00+03', 3.41);
INSERT INTO public.hourly_price VALUES ('2023-06-24 21:00:00+03', 6.45);
INSERT INTO public.hourly_price VALUES ('2023-06-24 22:00:00+03', 6.33);
INSERT INTO public.hourly_price VALUES ('2023-06-24 23:00:00+03', 6.58);
INSERT INTO public.hourly_price VALUES ('2023-06-25 00:00:00+03', 6.45);
INSERT INTO public.hourly_price VALUES ('2023-06-25 01:00:00+03', 6.24);
INSERT INTO public.hourly_price VALUES ('2023-06-25 02:00:00+03', 5.62);
INSERT INTO public.hourly_price VALUES ('2023-06-25 03:00:00+03', 4.78);
INSERT INTO public.hourly_price VALUES ('2023-06-25 04:00:00+03', 6.13);
INSERT INTO public.hourly_price VALUES ('2023-06-25 05:00:00+03', 5.67);
INSERT INTO public.hourly_price VALUES ('2023-06-25 06:00:00+03', 4.73);
INSERT INTO public.hourly_price VALUES ('2023-06-25 07:00:00+03', 4.31);
INSERT INTO public.hourly_price VALUES ('2023-06-25 08:00:00+03', 5.29);
INSERT INTO public.hourly_price VALUES ('2023-06-25 09:00:00+03', 5.75);
INSERT INTO public.hourly_price VALUES ('2023-06-25 10:00:00+03', 6.65);
INSERT INTO public.hourly_price VALUES ('2023-06-25 11:00:00+03', 6.93);
INSERT INTO public.hourly_price VALUES ('2023-06-25 12:00:00+03', 6.7);
INSERT INTO public.hourly_price VALUES ('2023-06-25 13:00:00+03', 4.04);
INSERT INTO public.hourly_price VALUES ('2023-06-25 14:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-06-25 15:00:00+03', 0.02);
INSERT INTO public.hourly_price VALUES ('2023-06-25 16:00:00+03', 0.11);
INSERT INTO public.hourly_price VALUES ('2023-06-25 17:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-06-25 18:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-06-25 19:00:00+03', 0.69);
INSERT INTO public.hourly_price VALUES ('2023-06-25 20:00:00+03', 2.68);
INSERT INTO public.hourly_price VALUES ('2023-06-25 21:00:00+03', 7.34);
INSERT INTO public.hourly_price VALUES ('2023-06-25 22:00:00+03', 7.68);
INSERT INTO public.hourly_price VALUES ('2023-06-25 23:00:00+03', 7.63);
INSERT INTO public.hourly_price VALUES ('2023-06-26 00:00:00+03', 7.51);
INSERT INTO public.hourly_price VALUES ('2023-06-26 01:00:00+03', 7.44);
INSERT INTO public.hourly_price VALUES ('2023-06-26 02:00:00+03', 7.25);
INSERT INTO public.hourly_price VALUES ('2023-06-26 03:00:00+03', 6.98);
INSERT INTO public.hourly_price VALUES ('2023-06-26 04:00:00+03', 8.05);
INSERT INTO public.hourly_price VALUES ('2023-06-26 05:00:00+03', 7.5);
INSERT INTO public.hourly_price VALUES ('2023-06-26 06:00:00+03', 7.43);
INSERT INTO public.hourly_price VALUES ('2023-06-26 07:00:00+03', 7.34);
INSERT INTO public.hourly_price VALUES ('2023-06-26 08:00:00+03', 7.37);
INSERT INTO public.hourly_price VALUES ('2023-06-26 09:00:00+03', 8.06);
INSERT INTO public.hourly_price VALUES ('2023-06-26 10:00:00+03', 9.18);
INSERT INTO public.hourly_price VALUES ('2023-06-26 11:00:00+03', 16.08);
INSERT INTO public.hourly_price VALUES ('2023-06-26 12:00:00+03', 14.95);
INSERT INTO public.hourly_price VALUES ('2023-06-26 13:00:00+03', 12.59);
INSERT INTO public.hourly_price VALUES ('2023-06-26 14:00:00+03', 10.9);
INSERT INTO public.hourly_price VALUES ('2023-06-26 15:00:00+03', 10.09);
INSERT INTO public.hourly_price VALUES ('2023-06-26 16:00:00+03', 9.87);
INSERT INTO public.hourly_price VALUES ('2023-06-26 17:00:00+03', 9.13);
INSERT INTO public.hourly_price VALUES ('2023-06-26 18:00:00+03', 9.1);
INSERT INTO public.hourly_price VALUES ('2023-06-26 19:00:00+03', 10.45);
INSERT INTO public.hourly_price VALUES ('2023-06-26 20:00:00+03', 11.25);
INSERT INTO public.hourly_price VALUES ('2023-06-26 21:00:00+03', 10.08);
INSERT INTO public.hourly_price VALUES ('2023-06-26 22:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-06-26 23:00:00+03', 11.63);
INSERT INTO public.hourly_price VALUES ('2023-06-27 00:00:00+03', 10.53);
INSERT INTO public.hourly_price VALUES ('2023-06-27 01:00:00+03', 8.6);
INSERT INTO public.hourly_price VALUES ('2023-06-27 02:00:00+03', 7.87);
INSERT INTO public.hourly_price VALUES ('2023-06-27 03:00:00+03', 7.06);
INSERT INTO public.hourly_price VALUES ('2023-06-27 04:00:00+03', 8.06);
INSERT INTO public.hourly_price VALUES ('2023-06-27 05:00:00+03', 7.76);
INSERT INTO public.hourly_price VALUES ('2023-06-27 06:00:00+03', 7.85);
INSERT INTO public.hourly_price VALUES ('2023-06-27 07:00:00+03', 8.07);
INSERT INTO public.hourly_price VALUES ('2023-06-27 08:00:00+03', 8.41);
INSERT INTO public.hourly_price VALUES ('2023-06-27 09:00:00+03', 8.99);
INSERT INTO public.hourly_price VALUES ('2023-06-27 10:00:00+03', 12.65);
INSERT INTO public.hourly_price VALUES ('2023-06-27 11:00:00+03', 11.16);
INSERT INTO public.hourly_price VALUES ('2023-06-27 12:00:00+03', 11.23);
INSERT INTO public.hourly_price VALUES ('2023-06-27 13:00:00+03', 9.65);
INSERT INTO public.hourly_price VALUES ('2023-06-27 14:00:00+03', 9.87);
INSERT INTO public.hourly_price VALUES ('2023-06-27 15:00:00+03', 9.72);
INSERT INTO public.hourly_price VALUES ('2023-06-27 16:00:00+03', 8.77);
INSERT INTO public.hourly_price VALUES ('2023-06-27 17:00:00+03', 8.06);
INSERT INTO public.hourly_price VALUES ('2023-06-27 18:00:00+03', 8.45);
INSERT INTO public.hourly_price VALUES ('2023-06-27 19:00:00+03', 9.43);
INSERT INTO public.hourly_price VALUES ('2023-06-27 20:00:00+03', 9.47);
INSERT INTO public.hourly_price VALUES ('2023-06-27 21:00:00+03', 10.02);
INSERT INTO public.hourly_price VALUES ('2023-06-27 22:00:00+03', 11.38);
INSERT INTO public.hourly_price VALUES ('2023-06-27 23:00:00+03', 12.97);
INSERT INTO public.hourly_price VALUES ('2023-06-28 00:00:00+03', 11.88);
INSERT INTO public.hourly_price VALUES ('2023-06-28 01:00:00+03', 14.2);
INSERT INTO public.hourly_price VALUES ('2023-06-28 02:00:00+03', 11.37);
INSERT INTO public.hourly_price VALUES ('2023-06-28 03:00:00+03', 9.8);
INSERT INTO public.hourly_price VALUES ('2023-06-28 04:00:00+03', 10.14);
INSERT INTO public.hourly_price VALUES ('2023-06-28 05:00:00+03', 9.49);
INSERT INTO public.hourly_price VALUES ('2023-06-28 06:00:00+03', 9.23);
INSERT INTO public.hourly_price VALUES ('2023-06-28 07:00:00+03', 9.19);
INSERT INTO public.hourly_price VALUES ('2023-06-28 08:00:00+03', 9.23);
INSERT INTO public.hourly_price VALUES ('2023-06-28 09:00:00+03', 11.42);
INSERT INTO public.hourly_price VALUES ('2023-06-28 10:00:00+03', 14.39);
INSERT INTO public.hourly_price VALUES ('2023-06-28 11:00:00+03', 16.31);
INSERT INTO public.hourly_price VALUES ('2023-06-28 12:00:00+03', 15.86);
INSERT INTO public.hourly_price VALUES ('2023-06-28 13:00:00+03', 14.09);
INSERT INTO public.hourly_price VALUES ('2023-06-28 14:00:00+03', 12.63);
INSERT INTO public.hourly_price VALUES ('2023-06-28 15:00:00+03', 12.31);
INSERT INTO public.hourly_price VALUES ('2023-06-28 16:00:00+03', 12.55);
INSERT INTO public.hourly_price VALUES ('2023-06-28 17:00:00+03', 12.08);
INSERT INTO public.hourly_price VALUES ('2023-06-28 18:00:00+03', 11.85);
INSERT INTO public.hourly_price VALUES ('2023-06-28 19:00:00+03', 11.83);
INSERT INTO public.hourly_price VALUES ('2023-06-28 20:00:00+03', 12.1);
INSERT INTO public.hourly_price VALUES ('2023-06-28 21:00:00+03', 13.28);
INSERT INTO public.hourly_price VALUES ('2023-06-28 22:00:00+03', 15.99);
INSERT INTO public.hourly_price VALUES ('2023-06-28 23:00:00+03', 19.24);
INSERT INTO public.hourly_price VALUES ('2023-06-29 00:00:00+03', 20.63);
INSERT INTO public.hourly_price VALUES ('2023-06-29 01:00:00+03', 19.54);
INSERT INTO public.hourly_price VALUES ('2023-06-29 02:00:00+03', 17.36);
INSERT INTO public.hourly_price VALUES ('2023-06-29 03:00:00+03', 13.22);
INSERT INTO public.hourly_price VALUES ('2023-06-29 04:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-06-29 05:00:00+03', 11.52);
INSERT INTO public.hourly_price VALUES ('2023-06-29 06:00:00+03', 11.16);
INSERT INTO public.hourly_price VALUES ('2023-06-29 07:00:00+03', 11.15);
INSERT INTO public.hourly_price VALUES ('2023-06-29 08:00:00+03', 11.22);
INSERT INTO public.hourly_price VALUES ('2023-06-29 09:00:00+03', 12.95);
INSERT INTO public.hourly_price VALUES ('2023-06-29 10:00:00+03', 15.1);
INSERT INTO public.hourly_price VALUES ('2023-06-29 11:00:00+03', 16.19);
INSERT INTO public.hourly_price VALUES ('2023-06-29 12:00:00+03', 16.16);
INSERT INTO public.hourly_price VALUES ('2023-06-29 13:00:00+03', 14.43);
INSERT INTO public.hourly_price VALUES ('2023-06-29 14:00:00+03', 13.14);
INSERT INTO public.hourly_price VALUES ('2023-06-29 15:00:00+03', 12.23);
INSERT INTO public.hourly_price VALUES ('2023-06-29 16:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-06-29 17:00:00+03', 12.18);
INSERT INTO public.hourly_price VALUES ('2023-06-29 18:00:00+03', 12.23);
INSERT INTO public.hourly_price VALUES ('2023-06-29 19:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-06-29 20:00:00+03', 12.54);
INSERT INTO public.hourly_price VALUES ('2023-06-29 21:00:00+03', 13.89);
INSERT INTO public.hourly_price VALUES ('2023-06-29 22:00:00+03', 16.28);
INSERT INTO public.hourly_price VALUES ('2023-06-29 23:00:00+03', 20.62);
INSERT INTO public.hourly_price VALUES ('2023-06-30 00:00:00+03', 16.14);
INSERT INTO public.hourly_price VALUES ('2023-06-30 01:00:00+03', 14.06);
INSERT INTO public.hourly_price VALUES ('2023-06-30 02:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-06-30 03:00:00+03', 11.9);
INSERT INTO public.hourly_price VALUES ('2023-06-30 04:00:00+03', 10.55);
INSERT INTO public.hourly_price VALUES ('2023-06-30 05:00:00+03', 9.4);
INSERT INTO public.hourly_price VALUES ('2023-06-30 06:00:00+03', 9.14);
INSERT INTO public.hourly_price VALUES ('2023-06-30 07:00:00+03', 8.91);
INSERT INTO public.hourly_price VALUES ('2023-06-30 08:00:00+03', 8.93);
INSERT INTO public.hourly_price VALUES ('2023-06-30 09:00:00+03', 9.48);
INSERT INTO public.hourly_price VALUES ('2023-06-30 10:00:00+03', 10.32);
INSERT INTO public.hourly_price VALUES ('2023-06-30 11:00:00+03', 11.59);
INSERT INTO public.hourly_price VALUES ('2023-06-30 12:00:00+03', 12.16);
INSERT INTO public.hourly_price VALUES ('2023-06-30 13:00:00+03', 10.53);
INSERT INTO public.hourly_price VALUES ('2023-06-30 14:00:00+03', 10.54);
INSERT INTO public.hourly_price VALUES ('2023-06-30 15:00:00+03', 10.46);
INSERT INTO public.hourly_price VALUES ('2023-06-30 16:00:00+03', 10.09);
INSERT INTO public.hourly_price VALUES ('2023-06-30 17:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-06-30 18:00:00+03', 9.81);
INSERT INTO public.hourly_price VALUES ('2023-06-30 19:00:00+03', 9.46);
INSERT INTO public.hourly_price VALUES ('2023-06-30 20:00:00+03', 8.64);
INSERT INTO public.hourly_price VALUES ('2023-06-30 21:00:00+03', 8.54);
INSERT INTO public.hourly_price VALUES ('2023-06-30 22:00:00+03', 8.57);
INSERT INTO public.hourly_price VALUES ('2023-06-30 23:00:00+03', 8.46);
INSERT INTO public.hourly_price VALUES ('2023-07-01 00:00:00+03', 8.01);
INSERT INTO public.hourly_price VALUES ('2023-07-01 01:00:00+03', 7.46);
INSERT INTO public.hourly_price VALUES ('2023-07-01 02:00:00+03', 7.02);
INSERT INTO public.hourly_price VALUES ('2023-07-01 03:00:00+03', 4.95);
INSERT INTO public.hourly_price VALUES ('2023-07-01 04:00:00+03', 2.77);
INSERT INTO public.hourly_price VALUES ('2023-07-01 05:00:00+03', 2.54);
INSERT INTO public.hourly_price VALUES ('2023-07-01 06:00:00+03', 2.5);
INSERT INTO public.hourly_price VALUES ('2023-07-01 07:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-07-01 08:00:00+03', 2.45);
INSERT INTO public.hourly_price VALUES ('2023-07-01 09:00:00+03', 2.5);
INSERT INTO public.hourly_price VALUES ('2023-07-01 10:00:00+03', 3.47);
INSERT INTO public.hourly_price VALUES ('2023-07-01 11:00:00+03', 4.88);
INSERT INTO public.hourly_price VALUES ('2023-07-01 12:00:00+03', 3.13);
INSERT INTO public.hourly_price VALUES ('2023-07-01 13:00:00+03', 3.65);
INSERT INTO public.hourly_price VALUES ('2023-07-01 14:00:00+03', 3.7);
INSERT INTO public.hourly_price VALUES ('2023-07-01 15:00:00+03', 3.05);
INSERT INTO public.hourly_price VALUES ('2023-07-01 16:00:00+03', 2.09);
INSERT INTO public.hourly_price VALUES ('2023-07-01 17:00:00+03', 0.55);
INSERT INTO public.hourly_price VALUES ('2023-07-01 18:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-01 19:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-07-01 20:00:00+03', 1.57);
INSERT INTO public.hourly_price VALUES ('2023-07-01 21:00:00+03', 6.5);
INSERT INTO public.hourly_price VALUES ('2023-07-01 22:00:00+03', 6.92);
INSERT INTO public.hourly_price VALUES ('2023-07-01 23:00:00+03', 7.22);
INSERT INTO public.hourly_price VALUES ('2023-07-02 00:00:00+03', 6.93);
INSERT INTO public.hourly_price VALUES ('2023-07-02 01:00:00+03', 6.89);
INSERT INTO public.hourly_price VALUES ('2023-07-02 02:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-07-02 03:00:00+03', 5.62);
INSERT INTO public.hourly_price VALUES ('2023-07-02 04:00:00+03', 2.04);
INSERT INTO public.hourly_price VALUES ('2023-07-02 05:00:00+03', 0.39);
INSERT INTO public.hourly_price VALUES ('2023-07-02 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-02 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-02 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-02 09:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-02 10:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-02 11:00:00+03', -0.05);
INSERT INTO public.hourly_price VALUES ('2023-07-02 12:00:00+03', -0.3);
INSERT INTO public.hourly_price VALUES ('2023-07-02 13:00:00+03', -0.5);
INSERT INTO public.hourly_price VALUES ('2023-07-02 14:00:00+03', -0.42);
INSERT INTO public.hourly_price VALUES ('2023-07-02 15:00:00+03', -0.31);
INSERT INTO public.hourly_price VALUES ('2023-07-02 16:00:00+03', -0.25);
INSERT INTO public.hourly_price VALUES ('2023-07-02 17:00:00+03', -0.23);
INSERT INTO public.hourly_price VALUES ('2023-07-02 18:00:00+03', -0.23);
INSERT INTO public.hourly_price VALUES ('2023-07-02 19:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-07-02 20:00:00+03', -0.38);
INSERT INTO public.hourly_price VALUES ('2023-07-02 21:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-07-02 22:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-02 23:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-07-03 00:00:00+03', 3.53);
INSERT INTO public.hourly_price VALUES ('2023-07-03 01:00:00+03', 3.51);
INSERT INTO public.hourly_price VALUES ('2023-07-03 02:00:00+03', 2.64);
INSERT INTO public.hourly_price VALUES ('2023-07-03 03:00:00+03', 2.09);
INSERT INTO public.hourly_price VALUES ('2023-07-03 04:00:00+03', 2.67);
INSERT INTO public.hourly_price VALUES ('2023-07-03 05:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-07-03 06:00:00+03', 2.2);
INSERT INTO public.hourly_price VALUES ('2023-07-03 07:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-07-03 08:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-07-03 09:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-07-03 10:00:00+03', 4.95);
INSERT INTO public.hourly_price VALUES ('2023-07-03 11:00:00+03', 6.86);
INSERT INTO public.hourly_price VALUES ('2023-07-03 12:00:00+03', 7.15);
INSERT INTO public.hourly_price VALUES ('2023-07-03 13:00:00+03', 5.17);
INSERT INTO public.hourly_price VALUES ('2023-07-03 14:00:00+03', 2.61);
INSERT INTO public.hourly_price VALUES ('2023-07-03 15:00:00+03', 2.15);
INSERT INTO public.hourly_price VALUES ('2023-07-03 16:00:00+03', 2.05);
INSERT INTO public.hourly_price VALUES ('2023-07-03 17:00:00+03', 1.83);
INSERT INTO public.hourly_price VALUES ('2023-07-03 18:00:00+03', 1.38);
INSERT INTO public.hourly_price VALUES ('2023-07-03 19:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-07-03 20:00:00+03', 2.12);
INSERT INTO public.hourly_price VALUES ('2023-07-03 21:00:00+03', 2.72);
INSERT INTO public.hourly_price VALUES ('2023-07-03 22:00:00+03', 6.51);
INSERT INTO public.hourly_price VALUES ('2023-07-03 23:00:00+03', 7.02);
INSERT INTO public.hourly_price VALUES ('2023-07-04 00:00:00+03', 6.68);
INSERT INTO public.hourly_price VALUES ('2023-07-04 01:00:00+03', 6.35);
INSERT INTO public.hourly_price VALUES ('2023-07-04 02:00:00+03', 5.63);
INSERT INTO public.hourly_price VALUES ('2023-07-04 03:00:00+03', 4.58);
INSERT INTO public.hourly_price VALUES ('2023-07-04 04:00:00+03', 2.81);
INSERT INTO public.hourly_price VALUES ('2023-07-04 05:00:00+03', 2.67);
INSERT INTO public.hourly_price VALUES ('2023-07-04 06:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-07-04 07:00:00+03', 2.46);
INSERT INTO public.hourly_price VALUES ('2023-07-04 08:00:00+03', 2.69);
INSERT INTO public.hourly_price VALUES ('2023-07-04 09:00:00+03', 3.09);
INSERT INTO public.hourly_price VALUES ('2023-07-04 10:00:00+03', 5.83);
INSERT INTO public.hourly_price VALUES ('2023-07-04 11:00:00+03', 7.87);
INSERT INTO public.hourly_price VALUES ('2023-07-04 12:00:00+03', 8.05);
INSERT INTO public.hourly_price VALUES ('2023-07-04 13:00:00+03', 7.69);
INSERT INTO public.hourly_price VALUES ('2023-07-04 14:00:00+03', 4.61);
INSERT INTO public.hourly_price VALUES ('2023-07-04 15:00:00+03', 2.92);
INSERT INTO public.hourly_price VALUES ('2023-07-04 16:00:00+03', 3);
INSERT INTO public.hourly_price VALUES ('2023-07-04 17:00:00+03', 2.96);
INSERT INTO public.hourly_price VALUES ('2023-07-04 18:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-07-04 19:00:00+03', 4.86);
INSERT INTO public.hourly_price VALUES ('2023-07-04 20:00:00+03', 6.35);
INSERT INTO public.hourly_price VALUES ('2023-07-04 21:00:00+03', 6.67);
INSERT INTO public.hourly_price VALUES ('2023-07-04 22:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-07-04 23:00:00+03', 7.81);
INSERT INTO public.hourly_price VALUES ('2023-07-05 00:00:00+03', 7.56);
INSERT INTO public.hourly_price VALUES ('2023-07-05 01:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-07-05 02:00:00+03', 6.8);
INSERT INTO public.hourly_price VALUES ('2023-07-05 03:00:00+03', 6.2);
INSERT INTO public.hourly_price VALUES ('2023-07-05 04:00:00+03', 5.41);
INSERT INTO public.hourly_price VALUES ('2023-07-05 05:00:00+03', 4.29);
INSERT INTO public.hourly_price VALUES ('2023-07-05 06:00:00+03', 3.81);
INSERT INTO public.hourly_price VALUES ('2023-07-05 07:00:00+03', 3.72);
INSERT INTO public.hourly_price VALUES ('2023-07-05 08:00:00+03', 3.96);
INSERT INTO public.hourly_price VALUES ('2023-07-05 09:00:00+03', 4.79);
INSERT INTO public.hourly_price VALUES ('2023-07-05 10:00:00+03', 5.77);
INSERT INTO public.hourly_price VALUES ('2023-07-05 11:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-07-05 12:00:00+03', 7.22);
INSERT INTO public.hourly_price VALUES ('2023-07-05 13:00:00+03', 7.73);
INSERT INTO public.hourly_price VALUES ('2023-07-05 14:00:00+03', 7.7);
INSERT INTO public.hourly_price VALUES ('2023-07-05 15:00:00+03', 6.14);
INSERT INTO public.hourly_price VALUES ('2023-07-05 16:00:00+03', 5.68);
INSERT INTO public.hourly_price VALUES ('2023-07-05 17:00:00+03', 5.58);
INSERT INTO public.hourly_price VALUES ('2023-07-05 18:00:00+03', 5.35);
INSERT INTO public.hourly_price VALUES ('2023-07-05 19:00:00+03', 5.14);
INSERT INTO public.hourly_price VALUES ('2023-07-05 20:00:00+03', 4.86);
INSERT INTO public.hourly_price VALUES ('2023-07-05 21:00:00+03', 5.9);
INSERT INTO public.hourly_price VALUES ('2023-07-05 22:00:00+03', 7.31);
INSERT INTO public.hourly_price VALUES ('2023-07-05 23:00:00+03', 8.36);
INSERT INTO public.hourly_price VALUES ('2023-07-06 00:00:00+03', 7.75);
INSERT INTO public.hourly_price VALUES ('2023-07-06 01:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-07-06 02:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-07-06 03:00:00+03', 5.71);
INSERT INTO public.hourly_price VALUES ('2023-07-06 04:00:00+03', 5.03);
INSERT INTO public.hourly_price VALUES ('2023-07-06 05:00:00+03', 4.63);
INSERT INTO public.hourly_price VALUES ('2023-07-06 06:00:00+03', 4.56);
INSERT INTO public.hourly_price VALUES ('2023-07-06 07:00:00+03', 4.59);
INSERT INTO public.hourly_price VALUES ('2023-07-06 08:00:00+03', 5.13);
INSERT INTO public.hourly_price VALUES ('2023-07-06 09:00:00+03', 5.8);
INSERT INTO public.hourly_price VALUES ('2023-07-06 10:00:00+03', 6.84);
INSERT INTO public.hourly_price VALUES ('2023-07-06 11:00:00+03', 7.68);
INSERT INTO public.hourly_price VALUES ('2023-07-06 12:00:00+03', 7.97);
INSERT INTO public.hourly_price VALUES ('2023-07-06 13:00:00+03', 7.86);
INSERT INTO public.hourly_price VALUES ('2023-07-06 14:00:00+03', 7.77);
INSERT INTO public.hourly_price VALUES ('2023-07-06 15:00:00+03', 7.48);
INSERT INTO public.hourly_price VALUES ('2023-07-06 16:00:00+03', 7.01);
INSERT INTO public.hourly_price VALUES ('2023-07-06 17:00:00+03', 7.06);
INSERT INTO public.hourly_price VALUES ('2023-07-06 18:00:00+03', 6.92);
INSERT INTO public.hourly_price VALUES ('2023-07-06 19:00:00+03', 6.82);
INSERT INTO public.hourly_price VALUES ('2023-07-06 20:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-07-06 21:00:00+03', 7.6);
INSERT INTO public.hourly_price VALUES ('2023-07-06 22:00:00+03', 7.93);
INSERT INTO public.hourly_price VALUES ('2023-07-06 23:00:00+03', 7.96);
INSERT INTO public.hourly_price VALUES ('2023-07-07 00:00:00+03', 7.9);
INSERT INTO public.hourly_price VALUES ('2023-07-07 01:00:00+03', 7.61);
INSERT INTO public.hourly_price VALUES ('2023-07-07 02:00:00+03', 7.4);
INSERT INTO public.hourly_price VALUES ('2023-07-07 03:00:00+03', 6.82);
INSERT INTO public.hourly_price VALUES ('2023-07-07 04:00:00+03', 6.83);
INSERT INTO public.hourly_price VALUES ('2023-07-07 05:00:00+03', 6.66);
INSERT INTO public.hourly_price VALUES ('2023-07-07 06:00:00+03', 6.31);
INSERT INTO public.hourly_price VALUES ('2023-07-07 07:00:00+03', 6.15);
INSERT INTO public.hourly_price VALUES ('2023-07-07 08:00:00+03', 6.25);
INSERT INTO public.hourly_price VALUES ('2023-07-07 09:00:00+03', 6.73);
INSERT INTO public.hourly_price VALUES ('2023-07-07 10:00:00+03', 7.44);
INSERT INTO public.hourly_price VALUES ('2023-07-07 11:00:00+03', 8.08);
INSERT INTO public.hourly_price VALUES ('2023-07-07 12:00:00+03', 9.25);
INSERT INTO public.hourly_price VALUES ('2023-07-07 13:00:00+03', 9.27);
INSERT INTO public.hourly_price VALUES ('2023-07-07 14:00:00+03', 9.32);
INSERT INTO public.hourly_price VALUES ('2023-07-07 15:00:00+03', 9.03);
INSERT INTO public.hourly_price VALUES ('2023-07-07 16:00:00+03', 9.06);
INSERT INTO public.hourly_price VALUES ('2023-07-07 17:00:00+03', 8.06);
INSERT INTO public.hourly_price VALUES ('2023-07-07 18:00:00+03', 7.86);
INSERT INTO public.hourly_price VALUES ('2023-07-07 19:00:00+03', 7.99);
INSERT INTO public.hourly_price VALUES ('2023-07-07 20:00:00+03', 7.97);
INSERT INTO public.hourly_price VALUES ('2023-07-07 21:00:00+03', 7.97);
INSERT INTO public.hourly_price VALUES ('2023-07-07 22:00:00+03', 8.16);
INSERT INTO public.hourly_price VALUES ('2023-07-07 23:00:00+03', 8.17);
INSERT INTO public.hourly_price VALUES ('2023-07-08 00:00:00+03', 8.03);
INSERT INTO public.hourly_price VALUES ('2023-07-08 01:00:00+03', 7.9);
INSERT INTO public.hourly_price VALUES ('2023-07-08 02:00:00+03', 7.38);
INSERT INTO public.hourly_price VALUES ('2023-07-08 03:00:00+03', 6.89);
INSERT INTO public.hourly_price VALUES ('2023-07-08 04:00:00+03', 6.57);
INSERT INTO public.hourly_price VALUES ('2023-07-08 05:00:00+03', 6.02);
INSERT INTO public.hourly_price VALUES ('2023-07-08 06:00:00+03', 5.44);
INSERT INTO public.hourly_price VALUES ('2023-07-08 07:00:00+03', 5.18);
INSERT INTO public.hourly_price VALUES ('2023-07-08 08:00:00+03', 5.1);
INSERT INTO public.hourly_price VALUES ('2023-07-08 09:00:00+03', 5.36);
INSERT INTO public.hourly_price VALUES ('2023-07-08 10:00:00+03', 5.89);
INSERT INTO public.hourly_price VALUES ('2023-07-08 11:00:00+03', 6.66);
INSERT INTO public.hourly_price VALUES ('2023-07-08 12:00:00+03', 6.87);
INSERT INTO public.hourly_price VALUES ('2023-07-08 13:00:00+03', 6.85);
INSERT INTO public.hourly_price VALUES ('2023-07-08 14:00:00+03', 6.86);
INSERT INTO public.hourly_price VALUES ('2023-07-08 15:00:00+03', 5.74);
INSERT INTO public.hourly_price VALUES ('2023-07-08 16:00:00+03', 4.43);
INSERT INTO public.hourly_price VALUES ('2023-07-08 17:00:00+03', 2.79);
INSERT INTO public.hourly_price VALUES ('2023-07-08 18:00:00+03', 2.78);
INSERT INTO public.hourly_price VALUES ('2023-07-08 19:00:00+03', 5.16);
INSERT INTO public.hourly_price VALUES ('2023-07-08 20:00:00+03', 7.15);
INSERT INTO public.hourly_price VALUES ('2023-07-08 21:00:00+03', 7.19);
INSERT INTO public.hourly_price VALUES ('2023-07-08 22:00:00+03', 7.44);
INSERT INTO public.hourly_price VALUES ('2023-07-08 23:00:00+03', 7.5);
INSERT INTO public.hourly_price VALUES ('2023-07-09 00:00:00+03', 7.29);
INSERT INTO public.hourly_price VALUES ('2023-07-09 01:00:00+03', 7.06);
INSERT INTO public.hourly_price VALUES ('2023-07-09 02:00:00+03', 6.9);
INSERT INTO public.hourly_price VALUES ('2023-07-09 03:00:00+03', 6.85);
INSERT INTO public.hourly_price VALUES ('2023-07-09 04:00:00+03', 6.48);
INSERT INTO public.hourly_price VALUES ('2023-07-09 05:00:00+03', 6.35);
INSERT INTO public.hourly_price VALUES ('2023-07-09 06:00:00+03', 6.21);
INSERT INTO public.hourly_price VALUES ('2023-07-09 07:00:00+03', 6.2);
INSERT INTO public.hourly_price VALUES ('2023-07-09 08:00:00+03', 6.2);
INSERT INTO public.hourly_price VALUES ('2023-07-09 09:00:00+03', 6.27);
INSERT INTO public.hourly_price VALUES ('2023-07-09 10:00:00+03', 6.79);
INSERT INTO public.hourly_price VALUES ('2023-07-09 11:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-07-09 12:00:00+03', 7.16);
INSERT INTO public.hourly_price VALUES ('2023-07-09 13:00:00+03', 7.4);
INSERT INTO public.hourly_price VALUES ('2023-07-09 14:00:00+03', 7.28);
INSERT INTO public.hourly_price VALUES ('2023-07-09 15:00:00+03', 6.26);
INSERT INTO public.hourly_price VALUES ('2023-07-09 16:00:00+03', 5.67);
INSERT INTO public.hourly_price VALUES ('2023-07-09 17:00:00+03', 4.59);
INSERT INTO public.hourly_price VALUES ('2023-07-09 18:00:00+03', 5.56);
INSERT INTO public.hourly_price VALUES ('2023-07-09 19:00:00+03', 6.84);
INSERT INTO public.hourly_price VALUES ('2023-07-09 20:00:00+03', 7.86);
INSERT INTO public.hourly_price VALUES ('2023-07-09 21:00:00+03', 7.78);
INSERT INTO public.hourly_price VALUES ('2023-07-09 22:00:00+03', 8.05);
INSERT INTO public.hourly_price VALUES ('2023-07-09 23:00:00+03', 8.67);
INSERT INTO public.hourly_price VALUES ('2023-07-10 00:00:00+03', 8.17);
INSERT INTO public.hourly_price VALUES ('2023-07-10 01:00:00+03', 7.64);
INSERT INTO public.hourly_price VALUES ('2023-07-10 02:00:00+03', 7.25);
INSERT INTO public.hourly_price VALUES ('2023-07-10 03:00:00+03', 7.04);
INSERT INTO public.hourly_price VALUES ('2023-07-10 04:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-07-10 05:00:00+03', 6.9);
INSERT INTO public.hourly_price VALUES ('2023-07-10 06:00:00+03', 6.85);
INSERT INTO public.hourly_price VALUES ('2023-07-10 07:00:00+03', 6.86);
INSERT INTO public.hourly_price VALUES ('2023-07-10 08:00:00+03', 6.87);
INSERT INTO public.hourly_price VALUES ('2023-07-10 09:00:00+03', 7.07);
INSERT INTO public.hourly_price VALUES ('2023-07-10 10:00:00+03', 7.42);
INSERT INTO public.hourly_price VALUES ('2023-07-10 11:00:00+03', 10.69);
INSERT INTO public.hourly_price VALUES ('2023-07-10 12:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-07-10 13:00:00+03', 10.95);
INSERT INTO public.hourly_price VALUES ('2023-07-10 14:00:00+03', 9.42);
INSERT INTO public.hourly_price VALUES ('2023-07-10 15:00:00+03', 8.48);
INSERT INTO public.hourly_price VALUES ('2023-07-10 16:00:00+03', 8.88);
INSERT INTO public.hourly_price VALUES ('2023-07-10 17:00:00+03', 8.48);
INSERT INTO public.hourly_price VALUES ('2023-07-10 18:00:00+03', 7.7);
INSERT INTO public.hourly_price VALUES ('2023-07-10 19:00:00+03', 7.66);
INSERT INTO public.hourly_price VALUES ('2023-07-10 20:00:00+03', 7.8);
INSERT INTO public.hourly_price VALUES ('2023-07-10 21:00:00+03', 9.63);
INSERT INTO public.hourly_price VALUES ('2023-07-10 22:00:00+03', 13.2);
INSERT INTO public.hourly_price VALUES ('2023-07-10 23:00:00+03', 11.75);
INSERT INTO public.hourly_price VALUES ('2023-07-11 00:00:00+03', 7.44);
INSERT INTO public.hourly_price VALUES ('2023-07-11 01:00:00+03', 7.21);
INSERT INTO public.hourly_price VALUES ('2023-07-11 02:00:00+03', 6.85);
INSERT INTO public.hourly_price VALUES ('2023-07-11 03:00:00+03', 6.23);
INSERT INTO public.hourly_price VALUES ('2023-07-11 04:00:00+03', 6.3);
INSERT INTO public.hourly_price VALUES ('2023-07-11 05:00:00+03', 6.15);
INSERT INTO public.hourly_price VALUES ('2023-07-11 06:00:00+03', 6.05);
INSERT INTO public.hourly_price VALUES ('2023-07-11 07:00:00+03', 6.14);
INSERT INTO public.hourly_price VALUES ('2023-07-11 08:00:00+03', 6.32);
INSERT INTO public.hourly_price VALUES ('2023-07-11 09:00:00+03', 6.73);
INSERT INTO public.hourly_price VALUES ('2023-07-11 10:00:00+03', 6.93);
INSERT INTO public.hourly_price VALUES ('2023-07-11 11:00:00+03', 7.68);
INSERT INTO public.hourly_price VALUES ('2023-07-11 12:00:00+03', 8.87);
INSERT INTO public.hourly_price VALUES ('2023-07-11 13:00:00+03', 7.68);
INSERT INTO public.hourly_price VALUES ('2023-07-11 14:00:00+03', 7.41);
INSERT INTO public.hourly_price VALUES ('2023-07-11 15:00:00+03', 7.68);
INSERT INTO public.hourly_price VALUES ('2023-07-11 16:00:00+03', 6.94);
INSERT INTO public.hourly_price VALUES ('2023-07-11 17:00:00+03', 5.89);
INSERT INTO public.hourly_price VALUES ('2023-07-11 18:00:00+03', 5.88);
INSERT INTO public.hourly_price VALUES ('2023-07-11 19:00:00+03', 7.18);
INSERT INTO public.hourly_price VALUES ('2023-07-11 20:00:00+03', 7.34);
INSERT INTO public.hourly_price VALUES ('2023-07-11 21:00:00+03', 7.33);
INSERT INTO public.hourly_price VALUES ('2023-07-11 22:00:00+03', 7.68);
INSERT INTO public.hourly_price VALUES ('2023-07-11 23:00:00+03', 7.41);
INSERT INTO public.hourly_price VALUES ('2023-07-12 00:00:00+03', 7.19);
INSERT INTO public.hourly_price VALUES ('2023-07-12 01:00:00+03', 6.2);
INSERT INTO public.hourly_price VALUES ('2023-07-12 02:00:00+03', 5.66);
INSERT INTO public.hourly_price VALUES ('2023-07-12 03:00:00+03', 4.69);
INSERT INTO public.hourly_price VALUES ('2023-07-12 04:00:00+03', 4.01);
INSERT INTO public.hourly_price VALUES ('2023-07-12 05:00:00+03', 3.29);
INSERT INTO public.hourly_price VALUES ('2023-07-12 06:00:00+03', 2.77);
INSERT INTO public.hourly_price VALUES ('2023-07-12 07:00:00+03', 2.93);
INSERT INTO public.hourly_price VALUES ('2023-07-12 08:00:00+03', 3.75);
INSERT INTO public.hourly_price VALUES ('2023-07-12 09:00:00+03', 4.84);
INSERT INTO public.hourly_price VALUES ('2023-07-12 10:00:00+03', 5.15);
INSERT INTO public.hourly_price VALUES ('2023-07-12 11:00:00+03', 6.26);
INSERT INTO public.hourly_price VALUES ('2023-07-12 12:00:00+03', 6.44);
INSERT INTO public.hourly_price VALUES ('2023-07-12 13:00:00+03', 6.66);
INSERT INTO public.hourly_price VALUES ('2023-07-12 14:00:00+03', 6.74);
INSERT INTO public.hourly_price VALUES ('2023-07-12 15:00:00+03', 6.3);
INSERT INTO public.hourly_price VALUES ('2023-07-12 16:00:00+03', 5.92);
INSERT INTO public.hourly_price VALUES ('2023-07-12 17:00:00+03', 5.32);
INSERT INTO public.hourly_price VALUES ('2023-07-12 18:00:00+03', 5.33);
INSERT INTO public.hourly_price VALUES ('2023-07-12 19:00:00+03', 6.03);
INSERT INTO public.hourly_price VALUES ('2023-07-12 20:00:00+03', 6.27);
INSERT INTO public.hourly_price VALUES ('2023-07-12 21:00:00+03', 5.43);
INSERT INTO public.hourly_price VALUES ('2023-07-12 22:00:00+03', 6.21);
INSERT INTO public.hourly_price VALUES ('2023-07-12 23:00:00+03', 6.33);
INSERT INTO public.hourly_price VALUES ('2023-07-13 00:00:00+03', 5.84);
INSERT INTO public.hourly_price VALUES ('2023-07-13 01:00:00+03', 5.59);
INSERT INTO public.hourly_price VALUES ('2023-07-13 02:00:00+03', 5.31);
INSERT INTO public.hourly_price VALUES ('2023-07-13 03:00:00+03', 4.58);
INSERT INTO public.hourly_price VALUES ('2023-07-13 04:00:00+03', 5.1);
INSERT INTO public.hourly_price VALUES ('2023-07-13 05:00:00+03', 5.03);
INSERT INTO public.hourly_price VALUES ('2023-07-13 06:00:00+03', 4.94);
INSERT INTO public.hourly_price VALUES ('2023-07-13 07:00:00+03', 4.84);
INSERT INTO public.hourly_price VALUES ('2023-07-13 08:00:00+03', 4.95);
INSERT INTO public.hourly_price VALUES ('2023-07-13 09:00:00+03', 5.05);
INSERT INTO public.hourly_price VALUES ('2023-07-13 10:00:00+03', 5.11);
INSERT INTO public.hourly_price VALUES ('2023-07-13 11:00:00+03', 5.5);
INSERT INTO public.hourly_price VALUES ('2023-07-13 12:00:00+03', 5.89);
INSERT INTO public.hourly_price VALUES ('2023-07-13 13:00:00+03', 6.08);
INSERT INTO public.hourly_price VALUES ('2023-07-13 14:00:00+03', 6.05);
INSERT INTO public.hourly_price VALUES ('2023-07-13 15:00:00+03', 5.9);
INSERT INTO public.hourly_price VALUES ('2023-07-13 16:00:00+03', 6.12);
INSERT INTO public.hourly_price VALUES ('2023-07-13 17:00:00+03', 5.77);
INSERT INTO public.hourly_price VALUES ('2023-07-13 18:00:00+03', 5.77);
INSERT INTO public.hourly_price VALUES ('2023-07-13 19:00:00+03', 5.8);
INSERT INTO public.hourly_price VALUES ('2023-07-13 20:00:00+03', 5.59);
INSERT INTO public.hourly_price VALUES ('2023-07-13 21:00:00+03', 5.82);
INSERT INTO public.hourly_price VALUES ('2023-07-13 22:00:00+03', 6.2);
INSERT INTO public.hourly_price VALUES ('2023-07-13 23:00:00+03', 6.34);
INSERT INTO public.hourly_price VALUES ('2023-07-14 00:00:00+03', 6.2);
INSERT INTO public.hourly_price VALUES ('2023-07-14 01:00:00+03', 5.86);
INSERT INTO public.hourly_price VALUES ('2023-07-14 02:00:00+03', 5.57);
INSERT INTO public.hourly_price VALUES ('2023-07-14 03:00:00+03', 5.34);
INSERT INTO public.hourly_price VALUES ('2023-07-14 04:00:00+03', 4.68);
INSERT INTO public.hourly_price VALUES ('2023-07-14 05:00:00+03', 4.59);
INSERT INTO public.hourly_price VALUES ('2023-07-14 06:00:00+03', 4.51);
INSERT INTO public.hourly_price VALUES ('2023-07-14 07:00:00+03', 4.55);
INSERT INTO public.hourly_price VALUES ('2023-07-14 08:00:00+03', 4.65);
INSERT INTO public.hourly_price VALUES ('2023-07-14 09:00:00+03', 5.02);
INSERT INTO public.hourly_price VALUES ('2023-07-14 10:00:00+03', 5.57);
INSERT INTO public.hourly_price VALUES ('2023-07-14 11:00:00+03', 5.57);
INSERT INTO public.hourly_price VALUES ('2023-07-14 12:00:00+03', 5.73);
INSERT INTO public.hourly_price VALUES ('2023-07-14 13:00:00+03', 5.82);
INSERT INTO public.hourly_price VALUES ('2023-07-14 14:00:00+03', 5.57);
INSERT INTO public.hourly_price VALUES ('2023-07-14 15:00:00+03', 5.48);
INSERT INTO public.hourly_price VALUES ('2023-07-14 16:00:00+03', 5.56);
INSERT INTO public.hourly_price VALUES ('2023-07-14 17:00:00+03', 5.43);
INSERT INTO public.hourly_price VALUES ('2023-07-14 18:00:00+03', 5.34);
INSERT INTO public.hourly_price VALUES ('2023-07-14 19:00:00+03', 5.26);
INSERT INTO public.hourly_price VALUES ('2023-07-14 20:00:00+03', 5.27);
INSERT INTO public.hourly_price VALUES ('2023-07-14 21:00:00+03', 5.57);
INSERT INTO public.hourly_price VALUES ('2023-07-14 22:00:00+03', 5.58);
INSERT INTO public.hourly_price VALUES ('2023-07-14 23:00:00+03', 5.69);
INSERT INTO public.hourly_price VALUES ('2023-07-15 00:00:00+03', 5.6);
INSERT INTO public.hourly_price VALUES ('2023-07-15 01:00:00+03', 5.41);
INSERT INTO public.hourly_price VALUES ('2023-07-15 02:00:00+03', 5.3);
INSERT INTO public.hourly_price VALUES ('2023-07-15 03:00:00+03', 4.96);
INSERT INTO public.hourly_price VALUES ('2023-07-15 04:00:00+03', 4.63);
INSERT INTO public.hourly_price VALUES ('2023-07-15 05:00:00+03', 4.53);
INSERT INTO public.hourly_price VALUES ('2023-07-15 06:00:00+03', 3.61);
INSERT INTO public.hourly_price VALUES ('2023-07-15 07:00:00+03', 2.47);
INSERT INTO public.hourly_price VALUES ('2023-07-15 08:00:00+03', 2.11);
INSERT INTO public.hourly_price VALUES ('2023-07-15 09:00:00+03', 1.7);
INSERT INTO public.hourly_price VALUES ('2023-07-15 10:00:00+03', 2.47);
INSERT INTO public.hourly_price VALUES ('2023-07-15 11:00:00+03', 2.8);
INSERT INTO public.hourly_price VALUES ('2023-07-15 12:00:00+03', 3.7);
INSERT INTO public.hourly_price VALUES ('2023-07-15 13:00:00+03', 2.16);
INSERT INTO public.hourly_price VALUES ('2023-07-15 14:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-07-15 15:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-15 16:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-15 17:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-15 18:00:00+03', -0.1);
INSERT INTO public.hourly_price VALUES ('2023-07-15 19:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-15 20:00:00+03', 0.22);
INSERT INTO public.hourly_price VALUES ('2023-07-15 21:00:00+03', 2.59);
INSERT INTO public.hourly_price VALUES ('2023-07-15 22:00:00+03', 4.4);
INSERT INTO public.hourly_price VALUES ('2023-07-15 23:00:00+03', 4.44);
INSERT INTO public.hourly_price VALUES ('2023-07-16 00:00:00+03', 4.16);
INSERT INTO public.hourly_price VALUES ('2023-07-16 01:00:00+03', 3.8);
INSERT INTO public.hourly_price VALUES ('2023-07-16 02:00:00+03', 2.57);
INSERT INTO public.hourly_price VALUES ('2023-07-16 03:00:00+03', 2.01);
INSERT INTO public.hourly_price VALUES ('2023-07-16 04:00:00+03', 1.71);
INSERT INTO public.hourly_price VALUES ('2023-07-16 05:00:00+03', 1.54);
INSERT INTO public.hourly_price VALUES ('2023-07-16 06:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-07-16 07:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-16 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-16 09:00:00+03', -0.04);
INSERT INTO public.hourly_price VALUES ('2023-07-16 10:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-07-16 11:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-07-16 12:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-07-16 13:00:00+03', -0.53);
INSERT INTO public.hourly_price VALUES ('2023-07-16 14:00:00+03', -0.68);
INSERT INTO public.hourly_price VALUES ('2023-07-16 15:00:00+03', -1.3);
INSERT INTO public.hourly_price VALUES ('2023-07-16 16:00:00+03', -3.84);
INSERT INTO public.hourly_price VALUES ('2023-07-16 17:00:00+03', -5.01);
INSERT INTO public.hourly_price VALUES ('2023-07-16 18:00:00+03', -6);
INSERT INTO public.hourly_price VALUES ('2023-07-16 19:00:00+03', -4.83);
INSERT INTO public.hourly_price VALUES ('2023-07-16 20:00:00+03', -1.01);
INSERT INTO public.hourly_price VALUES ('2023-07-16 21:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-07-16 22:00:00+03', 0.54);
INSERT INTO public.hourly_price VALUES ('2023-07-16 23:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-07-17 00:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-07-17 01:00:00+03', 0.11);
INSERT INTO public.hourly_price VALUES ('2023-07-17 02:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-07-17 03:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-17 04:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-17 05:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-17 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-17 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-17 08:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-07-17 09:00:00+03', 0.4);
INSERT INTO public.hourly_price VALUES ('2023-07-17 10:00:00+03', 0.57);
INSERT INTO public.hourly_price VALUES ('2023-07-17 11:00:00+03', 0.74);
INSERT INTO public.hourly_price VALUES ('2023-07-17 12:00:00+03', 0.7);
INSERT INTO public.hourly_price VALUES ('2023-07-17 13:00:00+03', 0.41);
INSERT INTO public.hourly_price VALUES ('2023-07-17 14:00:00+03', 0.44);
INSERT INTO public.hourly_price VALUES ('2023-07-17 15:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-07-17 16:00:00+03', 0.11);
INSERT INTO public.hourly_price VALUES ('2023-07-17 17:00:00+03', 0.07);
INSERT INTO public.hourly_price VALUES ('2023-07-17 18:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-17 19:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-17 20:00:00+03', 0.16);
INSERT INTO public.hourly_price VALUES ('2023-07-17 21:00:00+03', 0.73);
INSERT INTO public.hourly_price VALUES ('2023-07-17 22:00:00+03', 1.2);
INSERT INTO public.hourly_price VALUES ('2023-07-17 23:00:00+03', 2.1);
INSERT INTO public.hourly_price VALUES ('2023-07-18 00:00:00+03', 2.05);
INSERT INTO public.hourly_price VALUES ('2023-07-18 01:00:00+03', 2.02);
INSERT INTO public.hourly_price VALUES ('2023-07-18 02:00:00+03', 1.56);
INSERT INTO public.hourly_price VALUES ('2023-07-18 03:00:00+03', 1.09);
INSERT INTO public.hourly_price VALUES ('2023-07-18 04:00:00+03', 0.86);
INSERT INTO public.hourly_price VALUES ('2023-07-18 05:00:00+03', 0.75);
INSERT INTO public.hourly_price VALUES ('2023-07-18 06:00:00+03', 0.27);
INSERT INTO public.hourly_price VALUES ('2023-07-18 07:00:00+03', 0.1);
INSERT INTO public.hourly_price VALUES ('2023-07-18 08:00:00+03', 0.2);
INSERT INTO public.hourly_price VALUES ('2023-07-18 09:00:00+03', 0.6);
INSERT INTO public.hourly_price VALUES ('2023-07-18 10:00:00+03', 2.22);
INSERT INTO public.hourly_price VALUES ('2023-07-18 11:00:00+03', 2.49);
INSERT INTO public.hourly_price VALUES ('2023-07-18 12:00:00+03', 2.56);
INSERT INTO public.hourly_price VALUES ('2023-07-18 13:00:00+03', 2.55);
INSERT INTO public.hourly_price VALUES ('2023-07-18 14:00:00+03', 2.55);
INSERT INTO public.hourly_price VALUES ('2023-07-18 15:00:00+03', 2.57);
INSERT INTO public.hourly_price VALUES ('2023-07-18 16:00:00+03', 2.62);
INSERT INTO public.hourly_price VALUES ('2023-07-18 17:00:00+03', 2.65);
INSERT INTO public.hourly_price VALUES ('2023-07-18 18:00:00+03', 2.64);
INSERT INTO public.hourly_price VALUES ('2023-07-18 19:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-07-18 20:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-07-18 21:00:00+03', 2.67);
INSERT INTO public.hourly_price VALUES ('2023-07-18 22:00:00+03', 3.04);
INSERT INTO public.hourly_price VALUES ('2023-07-18 23:00:00+03', 3.32);
INSERT INTO public.hourly_price VALUES ('2023-07-19 00:00:00+03', 2.93);
INSERT INTO public.hourly_price VALUES ('2023-07-19 01:00:00+03', 2.64);
INSERT INTO public.hourly_price VALUES ('2023-07-19 02:00:00+03', 2.67);
INSERT INTO public.hourly_price VALUES ('2023-07-19 03:00:00+03', 2.54);
INSERT INTO public.hourly_price VALUES ('2023-07-19 04:00:00+03', 2.27);
INSERT INTO public.hourly_price VALUES ('2023-07-19 05:00:00+03', 2.24);
INSERT INTO public.hourly_price VALUES ('2023-07-19 06:00:00+03', 2.1);
INSERT INTO public.hourly_price VALUES ('2023-07-19 07:00:00+03', 2.21);
INSERT INTO public.hourly_price VALUES ('2023-07-19 08:00:00+03', 2.4);
INSERT INTO public.hourly_price VALUES ('2023-07-19 09:00:00+03', 2.61);
INSERT INTO public.hourly_price VALUES ('2023-07-19 10:00:00+03', 3.63);
INSERT INTO public.hourly_price VALUES ('2023-07-19 11:00:00+03', 4.22);
INSERT INTO public.hourly_price VALUES ('2023-07-19 12:00:00+03', 4.33);
INSERT INTO public.hourly_price VALUES ('2023-07-19 13:00:00+03', 4.22);
INSERT INTO public.hourly_price VALUES ('2023-07-19 14:00:00+03', 4.14);
INSERT INTO public.hourly_price VALUES ('2023-07-19 15:00:00+03', 3.98);
INSERT INTO public.hourly_price VALUES ('2023-07-19 16:00:00+03', 3.77);
INSERT INTO public.hourly_price VALUES ('2023-07-19 17:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-07-19 18:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-07-19 19:00:00+03', 3.79);
INSERT INTO public.hourly_price VALUES ('2023-07-19 20:00:00+03', 4.02);
INSERT INTO public.hourly_price VALUES ('2023-07-19 21:00:00+03', 4.21);
INSERT INTO public.hourly_price VALUES ('2023-07-19 22:00:00+03', 4.4);
INSERT INTO public.hourly_price VALUES ('2023-07-19 23:00:00+03', 4.57);
INSERT INTO public.hourly_price VALUES ('2023-07-20 00:00:00+03', 4.56);
INSERT INTO public.hourly_price VALUES ('2023-07-20 01:00:00+03', 4.51);
INSERT INTO public.hourly_price VALUES ('2023-07-20 02:00:00+03', 4.37);
INSERT INTO public.hourly_price VALUES ('2023-07-20 03:00:00+03', 3.84);
INSERT INTO public.hourly_price VALUES ('2023-07-20 04:00:00+03', 3.29);
INSERT INTO public.hourly_price VALUES ('2023-07-20 05:00:00+03', 2.74);
INSERT INTO public.hourly_price VALUES ('2023-07-20 06:00:00+03', 2.51);
INSERT INTO public.hourly_price VALUES ('2023-07-20 07:00:00+03', 2.51);
INSERT INTO public.hourly_price VALUES ('2023-07-20 08:00:00+03', 3.07);
INSERT INTO public.hourly_price VALUES ('2023-07-20 09:00:00+03', 3.6);
INSERT INTO public.hourly_price VALUES ('2023-07-20 10:00:00+03', 3.78);
INSERT INTO public.hourly_price VALUES ('2023-07-20 11:00:00+03', 4.11);
INSERT INTO public.hourly_price VALUES ('2023-07-20 12:00:00+03', 3.86);
INSERT INTO public.hourly_price VALUES ('2023-07-20 13:00:00+03', 3.7);
INSERT INTO public.hourly_price VALUES ('2023-07-20 14:00:00+03', 3.55);
INSERT INTO public.hourly_price VALUES ('2023-07-20 15:00:00+03', 3.42);
INSERT INTO public.hourly_price VALUES ('2023-07-20 16:00:00+03', 3.5);
INSERT INTO public.hourly_price VALUES ('2023-07-20 17:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-07-20 18:00:00+03', 3.13);
INSERT INTO public.hourly_price VALUES ('2023-07-20 19:00:00+03', 3.28);
INSERT INTO public.hourly_price VALUES ('2023-07-20 20:00:00+03', 2.97);
INSERT INTO public.hourly_price VALUES ('2023-07-20 21:00:00+03', 3.4);
INSERT INTO public.hourly_price VALUES ('2023-07-20 22:00:00+03', 3.58);
INSERT INTO public.hourly_price VALUES ('2023-07-20 23:00:00+03', 4.12);
INSERT INTO public.hourly_price VALUES ('2023-07-21 00:00:00+03', 3.95);
INSERT INTO public.hourly_price VALUES ('2023-07-21 01:00:00+03', 3.72);
INSERT INTO public.hourly_price VALUES ('2023-07-21 02:00:00+03', 3.51);
INSERT INTO public.hourly_price VALUES ('2023-07-21 03:00:00+03', 3.23);
INSERT INTO public.hourly_price VALUES ('2023-07-21 04:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-07-21 05:00:00+03', 2.54);
INSERT INTO public.hourly_price VALUES ('2023-07-21 06:00:00+03', 2.51);
INSERT INTO public.hourly_price VALUES ('2023-07-21 07:00:00+03', 2.49);
INSERT INTO public.hourly_price VALUES ('2023-07-21 08:00:00+03', 2.5);
INSERT INTO public.hourly_price VALUES ('2023-07-21 09:00:00+03', 3.14);
INSERT INTO public.hourly_price VALUES ('2023-07-21 10:00:00+03', 3.14);
INSERT INTO public.hourly_price VALUES ('2023-07-21 11:00:00+03', 3.44);
INSERT INTO public.hourly_price VALUES ('2023-07-21 12:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-07-21 13:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-07-21 14:00:00+03', 3.67);
INSERT INTO public.hourly_price VALUES ('2023-07-21 15:00:00+03', 3.67);
INSERT INTO public.hourly_price VALUES ('2023-07-21 16:00:00+03', 3.61);
INSERT INTO public.hourly_price VALUES ('2023-07-21 17:00:00+03', 3.41);
INSERT INTO public.hourly_price VALUES ('2023-07-21 18:00:00+03', 3.36);
INSERT INTO public.hourly_price VALUES ('2023-07-21 19:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-07-21 20:00:00+03', 3.49);
INSERT INTO public.hourly_price VALUES ('2023-07-21 21:00:00+03', 3.82);
INSERT INTO public.hourly_price VALUES ('2023-07-21 22:00:00+03', 3.84);
INSERT INTO public.hourly_price VALUES ('2023-07-21 23:00:00+03', 3.96);
INSERT INTO public.hourly_price VALUES ('2023-07-22 00:00:00+03', 3.9);
INSERT INTO public.hourly_price VALUES ('2023-07-22 01:00:00+03', 3.79);
INSERT INTO public.hourly_price VALUES ('2023-07-22 02:00:00+03', 3.72);
INSERT INTO public.hourly_price VALUES ('2023-07-22 03:00:00+03', 3.41);
INSERT INTO public.hourly_price VALUES ('2023-07-22 04:00:00+03', 2.65);
INSERT INTO public.hourly_price VALUES ('2023-07-22 05:00:00+03', 2.58);
INSERT INTO public.hourly_price VALUES ('2023-07-22 06:00:00+03', 2.54);
INSERT INTO public.hourly_price VALUES ('2023-07-22 07:00:00+03', 2.5);
INSERT INTO public.hourly_price VALUES ('2023-07-22 08:00:00+03', 2.49);
INSERT INTO public.hourly_price VALUES ('2023-07-22 09:00:00+03', 2.49);
INSERT INTO public.hourly_price VALUES ('2023-07-22 10:00:00+03', 2.58);
INSERT INTO public.hourly_price VALUES ('2023-07-22 11:00:00+03', 3.06);
INSERT INTO public.hourly_price VALUES ('2023-07-22 12:00:00+03', 3.26);
INSERT INTO public.hourly_price VALUES ('2023-07-22 13:00:00+03', 3.25);
INSERT INTO public.hourly_price VALUES ('2023-07-22 14:00:00+03', 3.18);
INSERT INTO public.hourly_price VALUES ('2023-07-22 15:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-07-22 16:00:00+03', 2.88);
INSERT INTO public.hourly_price VALUES ('2023-07-22 17:00:00+03', 2.63);
INSERT INTO public.hourly_price VALUES ('2023-07-22 18:00:00+03', 2.42);
INSERT INTO public.hourly_price VALUES ('2023-07-22 19:00:00+03', 2.58);
INSERT INTO public.hourly_price VALUES ('2023-07-22 20:00:00+03', 2.85);
INSERT INTO public.hourly_price VALUES ('2023-07-22 21:00:00+03', 3.25);
INSERT INTO public.hourly_price VALUES ('2023-07-22 22:00:00+03', 3.25);
INSERT INTO public.hourly_price VALUES ('2023-07-22 23:00:00+03', 3.33);
INSERT INTO public.hourly_price VALUES ('2023-07-23 00:00:00+03', 3.29);
INSERT INTO public.hourly_price VALUES ('2023-07-23 01:00:00+03', 3.29);
INSERT INTO public.hourly_price VALUES ('2023-07-23 02:00:00+03', 3.24);
INSERT INTO public.hourly_price VALUES ('2023-07-23 03:00:00+03', 2.81);
INSERT INTO public.hourly_price VALUES ('2023-07-23 04:00:00+03', 2.56);
INSERT INTO public.hourly_price VALUES ('2023-07-23 05:00:00+03', 2.52);
INSERT INTO public.hourly_price VALUES ('2023-07-23 06:00:00+03', 2.47);
INSERT INTO public.hourly_price VALUES ('2023-07-23 07:00:00+03', 2.47);
INSERT INTO public.hourly_price VALUES ('2023-07-23 08:00:00+03', 1.96);
INSERT INTO public.hourly_price VALUES ('2023-07-23 09:00:00+03', 1.38);
INSERT INTO public.hourly_price VALUES ('2023-07-23 10:00:00+03', 0.63);
INSERT INTO public.hourly_price VALUES ('2023-07-23 11:00:00+03', 0.36);
INSERT INTO public.hourly_price VALUES ('2023-07-23 12:00:00+03', 0.42);
INSERT INTO public.hourly_price VALUES ('2023-07-23 13:00:00+03', 0.02);
INSERT INTO public.hourly_price VALUES ('2023-07-23 14:00:00+03', 0.43);
INSERT INTO public.hourly_price VALUES ('2023-07-23 15:00:00+03', 0.57);
INSERT INTO public.hourly_price VALUES ('2023-07-23 16:00:00+03', 0.5);
INSERT INTO public.hourly_price VALUES ('2023-07-23 17:00:00+03', 0.5);
INSERT INTO public.hourly_price VALUES ('2023-07-23 18:00:00+03', 1);
INSERT INTO public.hourly_price VALUES ('2023-07-23 19:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-07-23 20:00:00+03', 1.53);
INSERT INTO public.hourly_price VALUES ('2023-07-23 21:00:00+03', 2.03);
INSERT INTO public.hourly_price VALUES ('2023-07-23 22:00:00+03', 2.75);
INSERT INTO public.hourly_price VALUES ('2023-07-23 23:00:00+03', 3.92);
INSERT INTO public.hourly_price VALUES ('2023-07-24 00:00:00+03', 3.65);
INSERT INTO public.hourly_price VALUES ('2023-07-24 01:00:00+03', 3.67);
INSERT INTO public.hourly_price VALUES ('2023-07-24 02:00:00+03', 3.41);
INSERT INTO public.hourly_price VALUES ('2023-07-24 03:00:00+03', 3.12);
INSERT INTO public.hourly_price VALUES ('2023-07-24 04:00:00+03', 2.68);
INSERT INTO public.hourly_price VALUES ('2023-07-24 05:00:00+03', 2.65);
INSERT INTO public.hourly_price VALUES ('2023-07-24 06:00:00+03', 2.68);
INSERT INTO public.hourly_price VALUES ('2023-07-24 07:00:00+03', 2.7);
INSERT INTO public.hourly_price VALUES ('2023-07-24 08:00:00+03', 2.69);
INSERT INTO public.hourly_price VALUES ('2023-07-24 09:00:00+03', 2.81);
INSERT INTO public.hourly_price VALUES ('2023-07-24 10:00:00+03', 3.31);
INSERT INTO public.hourly_price VALUES ('2023-07-24 11:00:00+03', 3.92);
INSERT INTO public.hourly_price VALUES ('2023-07-24 12:00:00+03', 4.2);
INSERT INTO public.hourly_price VALUES ('2023-07-24 13:00:00+03', 3.58);
INSERT INTO public.hourly_price VALUES ('2023-07-24 14:00:00+03', 3.94);
INSERT INTO public.hourly_price VALUES ('2023-07-24 15:00:00+03', 3.56);
INSERT INTO public.hourly_price VALUES ('2023-07-24 16:00:00+03', 3.4);
INSERT INTO public.hourly_price VALUES ('2023-07-24 17:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-07-24 18:00:00+03', 3.3);
INSERT INTO public.hourly_price VALUES ('2023-07-24 19:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-07-24 20:00:00+03', 3.53);
INSERT INTO public.hourly_price VALUES ('2023-07-24 21:00:00+03', 3.84);
INSERT INTO public.hourly_price VALUES ('2023-07-24 22:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-07-24 23:00:00+03', 4.11);
INSERT INTO public.hourly_price VALUES ('2023-07-25 00:00:00+03', 3.77);
INSERT INTO public.hourly_price VALUES ('2023-07-25 01:00:00+03', 3.59);
INSERT INTO public.hourly_price VALUES ('2023-07-25 02:00:00+03', 3.34);
INSERT INTO public.hourly_price VALUES ('2023-07-25 03:00:00+03', 2.92);
INSERT INTO public.hourly_price VALUES ('2023-07-25 04:00:00+03', 3.28);
INSERT INTO public.hourly_price VALUES ('2023-07-25 05:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-07-25 06:00:00+03', 2.96);
INSERT INTO public.hourly_price VALUES ('2023-07-25 07:00:00+03', 2.73);
INSERT INTO public.hourly_price VALUES ('2023-07-25 08:00:00+03', 2.66);
INSERT INTO public.hourly_price VALUES ('2023-07-25 09:00:00+03', 2.77);
INSERT INTO public.hourly_price VALUES ('2023-07-25 10:00:00+03', 3.28);
INSERT INTO public.hourly_price VALUES ('2023-07-25 11:00:00+03', 3.63);
INSERT INTO public.hourly_price VALUES ('2023-07-25 12:00:00+03', 3.54);
INSERT INTO public.hourly_price VALUES ('2023-07-25 13:00:00+03', 3.57);
INSERT INTO public.hourly_price VALUES ('2023-07-25 14:00:00+03', 3.39);
INSERT INTO public.hourly_price VALUES ('2023-07-25 15:00:00+03', 3.32);
INSERT INTO public.hourly_price VALUES ('2023-07-25 16:00:00+03', 3.12);
INSERT INTO public.hourly_price VALUES ('2023-07-25 17:00:00+03', 3.09);
INSERT INTO public.hourly_price VALUES ('2023-07-25 18:00:00+03', 3.01);
INSERT INTO public.hourly_price VALUES ('2023-07-25 19:00:00+03', 3.01);
INSERT INTO public.hourly_price VALUES ('2023-07-25 20:00:00+03', 3.06);
INSERT INTO public.hourly_price VALUES ('2023-07-25 21:00:00+03', 3.18);
INSERT INTO public.hourly_price VALUES ('2023-07-25 22:00:00+03', 3.26);
INSERT INTO public.hourly_price VALUES ('2023-07-25 23:00:00+03', 3.69);
INSERT INTO public.hourly_price VALUES ('2023-07-26 00:00:00+03', 3.52);
INSERT INTO public.hourly_price VALUES ('2023-07-26 01:00:00+03', 3.46);
INSERT INTO public.hourly_price VALUES ('2023-07-26 02:00:00+03', 3.36);
INSERT INTO public.hourly_price VALUES ('2023-07-26 03:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-07-26 04:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-07-26 05:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-07-26 06:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-07-26 07:00:00+03', 3.09);
INSERT INTO public.hourly_price VALUES ('2023-07-26 08:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-07-26 09:00:00+03', 3.29);
INSERT INTO public.hourly_price VALUES ('2023-07-26 10:00:00+03', 3.58);
INSERT INTO public.hourly_price VALUES ('2023-07-26 11:00:00+03', 3.81);
INSERT INTO public.hourly_price VALUES ('2023-07-26 12:00:00+03', 3.91);
INSERT INTO public.hourly_price VALUES ('2023-07-26 13:00:00+03', 3.87);
INSERT INTO public.hourly_price VALUES ('2023-07-26 14:00:00+03', 3.88);
INSERT INTO public.hourly_price VALUES ('2023-07-26 15:00:00+03', 3.79);
INSERT INTO public.hourly_price VALUES ('2023-07-26 16:00:00+03', 3.7);
INSERT INTO public.hourly_price VALUES ('2023-07-26 17:00:00+03', 3.68);
INSERT INTO public.hourly_price VALUES ('2023-07-26 18:00:00+03', 3.66);
INSERT INTO public.hourly_price VALUES ('2023-07-26 19:00:00+03', 3.7);
INSERT INTO public.hourly_price VALUES ('2023-07-26 20:00:00+03', 3.84);
INSERT INTO public.hourly_price VALUES ('2023-07-26 21:00:00+03', 4.08);
INSERT INTO public.hourly_price VALUES ('2023-07-26 22:00:00+03', 4.12);
INSERT INTO public.hourly_price VALUES ('2023-07-26 23:00:00+03', 4.06);
INSERT INTO public.hourly_price VALUES ('2023-07-27 00:00:00+03', 3.88);
INSERT INTO public.hourly_price VALUES ('2023-07-27 01:00:00+03', 3.84);
INSERT INTO public.hourly_price VALUES ('2023-07-27 02:00:00+03', 3.99);
INSERT INTO public.hourly_price VALUES ('2023-07-27 03:00:00+03', 3.66);
INSERT INTO public.hourly_price VALUES ('2023-07-27 04:00:00+03', 3.77);
INSERT INTO public.hourly_price VALUES ('2023-07-27 05:00:00+03', 3.71);
INSERT INTO public.hourly_price VALUES ('2023-07-27 06:00:00+03', 3.65);
INSERT INTO public.hourly_price VALUES ('2023-07-27 07:00:00+03', 3.63);
INSERT INTO public.hourly_price VALUES ('2023-07-27 08:00:00+03', 3.64);
INSERT INTO public.hourly_price VALUES ('2023-07-27 09:00:00+03', 3.78);
INSERT INTO public.hourly_price VALUES ('2023-07-27 10:00:00+03', 4.03);
INSERT INTO public.hourly_price VALUES ('2023-07-27 11:00:00+03', 4.28);
INSERT INTO public.hourly_price VALUES ('2023-07-27 12:00:00+03', 4.2);
INSERT INTO public.hourly_price VALUES ('2023-07-27 13:00:00+03', 4.21);
INSERT INTO public.hourly_price VALUES ('2023-07-27 14:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-07-27 15:00:00+03', 4.2);
INSERT INTO public.hourly_price VALUES ('2023-07-27 16:00:00+03', 4.21);
INSERT INTO public.hourly_price VALUES ('2023-07-27 17:00:00+03', 4.1);
INSERT INTO public.hourly_price VALUES ('2023-07-27 18:00:00+03', 4.07);
INSERT INTO public.hourly_price VALUES ('2023-07-27 19:00:00+03', 4.18);
INSERT INTO public.hourly_price VALUES ('2023-07-27 20:00:00+03', 4.24);
INSERT INTO public.hourly_price VALUES ('2023-07-27 21:00:00+03', 4.4);
INSERT INTO public.hourly_price VALUES ('2023-07-27 22:00:00+03', 4.47);
INSERT INTO public.hourly_price VALUES ('2023-07-27 23:00:00+03', 4.56);
INSERT INTO public.hourly_price VALUES ('2023-07-28 00:00:00+03', 4.51);
INSERT INTO public.hourly_price VALUES ('2023-07-28 01:00:00+03', 4.39);
INSERT INTO public.hourly_price VALUES ('2023-07-28 02:00:00+03', 4.24);
INSERT INTO public.hourly_price VALUES ('2023-07-28 03:00:00+03', 4.03);
INSERT INTO public.hourly_price VALUES ('2023-07-28 04:00:00+03', 4.01);
INSERT INTO public.hourly_price VALUES ('2023-07-28 05:00:00+03', 3.81);
INSERT INTO public.hourly_price VALUES ('2023-07-28 06:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-07-28 07:00:00+03', 3.73);
INSERT INTO public.hourly_price VALUES ('2023-07-28 08:00:00+03', 3.82);
INSERT INTO public.hourly_price VALUES ('2023-07-28 09:00:00+03', 4.13);
INSERT INTO public.hourly_price VALUES ('2023-07-28 10:00:00+03', 4.23);
INSERT INTO public.hourly_price VALUES ('2023-07-28 11:00:00+03', 4.35);
INSERT INTO public.hourly_price VALUES ('2023-07-28 12:00:00+03', 4.49);
INSERT INTO public.hourly_price VALUES ('2023-07-28 13:00:00+03', 4.51);
INSERT INTO public.hourly_price VALUES ('2023-07-28 14:00:00+03', 4.42);
INSERT INTO public.hourly_price VALUES ('2023-07-28 15:00:00+03', 4.39);
INSERT INTO public.hourly_price VALUES ('2023-07-28 16:00:00+03', 4.38);
INSERT INTO public.hourly_price VALUES ('2023-07-28 17:00:00+03', 4.33);
INSERT INTO public.hourly_price VALUES ('2023-07-28 18:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-07-28 19:00:00+03', 4.21);
INSERT INTO public.hourly_price VALUES ('2023-07-28 20:00:00+03', 4.22);
INSERT INTO public.hourly_price VALUES ('2023-07-28 21:00:00+03', 4.32);
INSERT INTO public.hourly_price VALUES ('2023-07-28 22:00:00+03', 4.43);
INSERT INTO public.hourly_price VALUES ('2023-07-28 23:00:00+03', 4.37);
INSERT INTO public.hourly_price VALUES ('2023-07-29 00:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-07-29 01:00:00+03', 4.19);
INSERT INTO public.hourly_price VALUES ('2023-07-29 02:00:00+03', 3.91);
INSERT INTO public.hourly_price VALUES ('2023-07-29 03:00:00+03', 3.52);
INSERT INTO public.hourly_price VALUES ('2023-07-29 04:00:00+03', 2.36);
INSERT INTO public.hourly_price VALUES ('2023-07-29 05:00:00+03', 1.34);
INSERT INTO public.hourly_price VALUES ('2023-07-29 06:00:00+03', 0.31);
INSERT INTO public.hourly_price VALUES ('2023-07-29 07:00:00+03', 0.18);
INSERT INTO public.hourly_price VALUES ('2023-07-29 08:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-07-29 09:00:00+03', 0.1);
INSERT INTO public.hourly_price VALUES ('2023-07-29 10:00:00+03', 0.75);
INSERT INTO public.hourly_price VALUES ('2023-07-29 11:00:00+03', 1.86);
INSERT INTO public.hourly_price VALUES ('2023-07-29 12:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-07-29 13:00:00+03', 2.57);
INSERT INTO public.hourly_price VALUES ('2023-07-29 14:00:00+03', 2.66);
INSERT INTO public.hourly_price VALUES ('2023-07-29 15:00:00+03', 2.75);
INSERT INTO public.hourly_price VALUES ('2023-07-29 16:00:00+03', 2.76);
INSERT INTO public.hourly_price VALUES ('2023-07-29 17:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-07-29 18:00:00+03', 2.26);
INSERT INTO public.hourly_price VALUES ('2023-07-29 19:00:00+03', 2.44);
INSERT INTO public.hourly_price VALUES ('2023-07-29 20:00:00+03', 3.33);
INSERT INTO public.hourly_price VALUES ('2023-07-29 21:00:00+03', 3.56);
INSERT INTO public.hourly_price VALUES ('2023-07-29 22:00:00+03', 3.59);
INSERT INTO public.hourly_price VALUES ('2023-07-29 23:00:00+03', 3.61);
INSERT INTO public.hourly_price VALUES ('2023-07-30 00:00:00+03', 3.45);
INSERT INTO public.hourly_price VALUES ('2023-07-30 01:00:00+03', 3.34);
INSERT INTO public.hourly_price VALUES ('2023-07-30 02:00:00+03', 3.23);
INSERT INTO public.hourly_price VALUES ('2023-07-30 03:00:00+03', 3.03);
INSERT INTO public.hourly_price VALUES ('2023-07-30 04:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-07-30 05:00:00+03', 3.06);
INSERT INTO public.hourly_price VALUES ('2023-07-30 06:00:00+03', 3.03);
INSERT INTO public.hourly_price VALUES ('2023-07-30 07:00:00+03', 3.09);
INSERT INTO public.hourly_price VALUES ('2023-07-30 08:00:00+03', 3.08);
INSERT INTO public.hourly_price VALUES ('2023-07-30 09:00:00+03', 3.04);
INSERT INTO public.hourly_price VALUES ('2023-07-30 10:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-07-30 11:00:00+03', 3.31);
INSERT INTO public.hourly_price VALUES ('2023-07-30 12:00:00+03', 3.38);
INSERT INTO public.hourly_price VALUES ('2023-07-30 13:00:00+03', 1.32);
INSERT INTO public.hourly_price VALUES ('2023-07-30 14:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-30 15:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-07-30 16:00:00+03', -0.08);
INSERT INTO public.hourly_price VALUES ('2023-07-30 17:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-30 18:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-07-30 19:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-07-30 20:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-07-30 21:00:00+03', 2.02);
INSERT INTO public.hourly_price VALUES ('2023-07-30 22:00:00+03', 3.39);
INSERT INTO public.hourly_price VALUES ('2023-07-30 23:00:00+03', 4.18);
INSERT INTO public.hourly_price VALUES ('2023-07-31 00:00:00+03', 4.11);
INSERT INTO public.hourly_price VALUES ('2023-07-31 01:00:00+03', 4.01);
INSERT INTO public.hourly_price VALUES ('2023-07-31 02:00:00+03', 3.88);
INSERT INTO public.hourly_price VALUES ('2023-07-31 03:00:00+03', 3.6);
INSERT INTO public.hourly_price VALUES ('2023-07-31 04:00:00+03', 3.72);
INSERT INTO public.hourly_price VALUES ('2023-07-31 05:00:00+03', 3.67);
INSERT INTO public.hourly_price VALUES ('2023-07-31 06:00:00+03', 3.66);
INSERT INTO public.hourly_price VALUES ('2023-07-31 07:00:00+03', 3.64);
INSERT INTO public.hourly_price VALUES ('2023-07-31 08:00:00+03', 3.5);
INSERT INTO public.hourly_price VALUES ('2023-07-31 09:00:00+03', 3.92);
INSERT INTO public.hourly_price VALUES ('2023-07-31 10:00:00+03', 5.14);
INSERT INTO public.hourly_price VALUES ('2023-07-31 11:00:00+03', 11.7);
INSERT INTO public.hourly_price VALUES ('2023-07-31 12:00:00+03', 11.25);
INSERT INTO public.hourly_price VALUES ('2023-07-31 13:00:00+03', 10.66);
INSERT INTO public.hourly_price VALUES ('2023-07-31 14:00:00+03', 9.06);
INSERT INTO public.hourly_price VALUES ('2023-07-31 15:00:00+03', 8.16);
INSERT INTO public.hourly_price VALUES ('2023-07-31 16:00:00+03', 7.81);
INSERT INTO public.hourly_price VALUES ('2023-07-31 17:00:00+03', 7.09);
INSERT INTO public.hourly_price VALUES ('2023-07-31 18:00:00+03', 7);
INSERT INTO public.hourly_price VALUES ('2023-07-31 19:00:00+03', 6.2);
INSERT INTO public.hourly_price VALUES ('2023-07-31 20:00:00+03', 8.01);
INSERT INTO public.hourly_price VALUES ('2023-07-31 21:00:00+03', 9.87);
INSERT INTO public.hourly_price VALUES ('2023-07-31 22:00:00+03', 10.98);
INSERT INTO public.hourly_price VALUES ('2023-07-31 23:00:00+03', 5.09);
INSERT INTO public.hourly_price VALUES ('2023-08-01 00:00:00+03', 4.33);
INSERT INTO public.hourly_price VALUES ('2023-08-01 01:00:00+03', 4.08);
INSERT INTO public.hourly_price VALUES ('2023-08-01 02:00:00+03', 3.82);
INSERT INTO public.hourly_price VALUES ('2023-08-01 03:00:00+03', 3.49);
INSERT INTO public.hourly_price VALUES ('2023-08-01 04:00:00+03', 3.23);
INSERT INTO public.hourly_price VALUES ('2023-08-01 05:00:00+03', 2.86);
INSERT INTO public.hourly_price VALUES ('2023-08-01 06:00:00+03', 2.46);
INSERT INTO public.hourly_price VALUES ('2023-08-01 07:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-08-01 08:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-08-01 09:00:00+03', 3.15);
INSERT INTO public.hourly_price VALUES ('2023-08-01 10:00:00+03', 3.54);
INSERT INTO public.hourly_price VALUES ('2023-08-01 11:00:00+03', 4.02);
INSERT INTO public.hourly_price VALUES ('2023-08-01 12:00:00+03', 4.21);
INSERT INTO public.hourly_price VALUES ('2023-08-01 13:00:00+03', 4.28);
INSERT INTO public.hourly_price VALUES ('2023-08-01 14:00:00+03', 4.21);
INSERT INTO public.hourly_price VALUES ('2023-08-01 15:00:00+03', 4.17);
INSERT INTO public.hourly_price VALUES ('2023-08-01 16:00:00+03', 4.14);
INSERT INTO public.hourly_price VALUES ('2023-08-01 17:00:00+03', 4.04);
INSERT INTO public.hourly_price VALUES ('2023-08-01 18:00:00+03', 4.08);
INSERT INTO public.hourly_price VALUES ('2023-08-01 19:00:00+03', 3.98);
INSERT INTO public.hourly_price VALUES ('2023-08-01 20:00:00+03', 3.99);
INSERT INTO public.hourly_price VALUES ('2023-08-01 21:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-08-01 22:00:00+03', 4.31);
INSERT INTO public.hourly_price VALUES ('2023-08-01 23:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-08-02 00:00:00+03', 4.01);
INSERT INTO public.hourly_price VALUES ('2023-08-02 01:00:00+03', 4.04);
INSERT INTO public.hourly_price VALUES ('2023-08-02 02:00:00+03', 3.71);
INSERT INTO public.hourly_price VALUES ('2023-08-02 03:00:00+03', 3.51);
INSERT INTO public.hourly_price VALUES ('2023-08-02 04:00:00+03', 2.79);
INSERT INTO public.hourly_price VALUES ('2023-08-02 05:00:00+03', 2.74);
INSERT INTO public.hourly_price VALUES ('2023-08-02 06:00:00+03', 2.46);
INSERT INTO public.hourly_price VALUES ('2023-08-02 07:00:00+03', 0.5);
INSERT INTO public.hourly_price VALUES ('2023-08-02 08:00:00+03', 2.45);
INSERT INTO public.hourly_price VALUES ('2023-08-02 09:00:00+03', 2.98);
INSERT INTO public.hourly_price VALUES ('2023-08-02 10:00:00+03', 3.4);
INSERT INTO public.hourly_price VALUES ('2023-08-02 11:00:00+03', 3.57);
INSERT INTO public.hourly_price VALUES ('2023-08-02 12:00:00+03', 3.68);
INSERT INTO public.hourly_price VALUES ('2023-08-02 13:00:00+03', 3.62);
INSERT INTO public.hourly_price VALUES ('2023-08-02 14:00:00+03', 3.47);
INSERT INTO public.hourly_price VALUES ('2023-08-02 15:00:00+03', 3.36);
INSERT INTO public.hourly_price VALUES ('2023-08-02 16:00:00+03', 3.21);
INSERT INTO public.hourly_price VALUES ('2023-08-02 17:00:00+03', 3.24);
INSERT INTO public.hourly_price VALUES ('2023-08-02 18:00:00+03', 2.93);
INSERT INTO public.hourly_price VALUES ('2023-08-02 19:00:00+03', 2.57);
INSERT INTO public.hourly_price VALUES ('2023-08-02 20:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-08-02 21:00:00+03', 3.39);
INSERT INTO public.hourly_price VALUES ('2023-08-02 22:00:00+03', 3.46);
INSERT INTO public.hourly_price VALUES ('2023-08-02 23:00:00+03', 3.45);
INSERT INTO public.hourly_price VALUES ('2023-08-03 00:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-08-03 01:00:00+03', 3.41);
INSERT INTO public.hourly_price VALUES ('2023-08-03 02:00:00+03', 3.29);
INSERT INTO public.hourly_price VALUES ('2023-08-03 03:00:00+03', 0.57);
INSERT INTO public.hourly_price VALUES ('2023-08-03 04:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-03 05:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-03 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-03 07:00:00+03', 0.03);
INSERT INTO public.hourly_price VALUES ('2023-08-03 08:00:00+03', 0.53);
INSERT INTO public.hourly_price VALUES ('2023-08-03 09:00:00+03', 0.94);
INSERT INTO public.hourly_price VALUES ('2023-08-03 10:00:00+03', 1.83);
INSERT INTO public.hourly_price VALUES ('2023-08-03 11:00:00+03', 2.58);
INSERT INTO public.hourly_price VALUES ('2023-08-03 12:00:00+03', 3.21);
INSERT INTO public.hourly_price VALUES ('2023-08-03 13:00:00+03', 3.4);
INSERT INTO public.hourly_price VALUES ('2023-08-03 14:00:00+03', 3.6);
INSERT INTO public.hourly_price VALUES ('2023-08-03 15:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-08-03 16:00:00+03', 3.28);
INSERT INTO public.hourly_price VALUES ('2023-08-03 17:00:00+03', 2.7);
INSERT INTO public.hourly_price VALUES ('2023-08-03 18:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-08-03 19:00:00+03', 2.26);
INSERT INTO public.hourly_price VALUES ('2023-08-03 20:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-08-03 21:00:00+03', 3.95);
INSERT INTO public.hourly_price VALUES ('2023-08-03 22:00:00+03', 3.91);
INSERT INTO public.hourly_price VALUES ('2023-08-03 23:00:00+03', 3.9);
INSERT INTO public.hourly_price VALUES ('2023-08-04 00:00:00+03', 3.74);
INSERT INTO public.hourly_price VALUES ('2023-08-04 01:00:00+03', 3.61);
INSERT INTO public.hourly_price VALUES ('2023-08-04 02:00:00+03', 3.42);
INSERT INTO public.hourly_price VALUES ('2023-08-04 03:00:00+03', 3.25);
INSERT INTO public.hourly_price VALUES ('2023-08-04 04:00:00+03', 2.19);
INSERT INTO public.hourly_price VALUES ('2023-08-04 05:00:00+03', 2.16);
INSERT INTO public.hourly_price VALUES ('2023-08-04 06:00:00+03', 2.13);
INSERT INTO public.hourly_price VALUES ('2023-08-04 07:00:00+03', 2);
INSERT INTO public.hourly_price VALUES ('2023-08-04 08:00:00+03', 1.86);
INSERT INTO public.hourly_price VALUES ('2023-08-04 09:00:00+03', 1.95);
INSERT INTO public.hourly_price VALUES ('2023-08-04 10:00:00+03', 2.19);
INSERT INTO public.hourly_price VALUES ('2023-08-04 11:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-08-04 12:00:00+03', 2.92);
INSERT INTO public.hourly_price VALUES ('2023-08-04 13:00:00+03', 3.08);
INSERT INTO public.hourly_price VALUES ('2023-08-04 14:00:00+03', 3.12);
INSERT INTO public.hourly_price VALUES ('2023-08-04 15:00:00+03', 3.07);
INSERT INTO public.hourly_price VALUES ('2023-08-04 16:00:00+03', 3.02);
INSERT INTO public.hourly_price VALUES ('2023-08-04 17:00:00+03', 2.74);
INSERT INTO public.hourly_price VALUES ('2023-08-04 18:00:00+03', 2.55);
INSERT INTO public.hourly_price VALUES ('2023-08-04 19:00:00+03', 2.5);
INSERT INTO public.hourly_price VALUES ('2023-08-04 20:00:00+03', 2.51);
INSERT INTO public.hourly_price VALUES ('2023-08-04 21:00:00+03', 2.91);
INSERT INTO public.hourly_price VALUES ('2023-08-04 22:00:00+03', 3.08);
INSERT INTO public.hourly_price VALUES ('2023-08-04 23:00:00+03', 3.04);
INSERT INTO public.hourly_price VALUES ('2023-08-05 00:00:00+03', 2.89);
INSERT INTO public.hourly_price VALUES ('2023-08-05 01:00:00+03', 2.59);
INSERT INTO public.hourly_price VALUES ('2023-08-05 02:00:00+03', 2.24);
INSERT INTO public.hourly_price VALUES ('2023-08-05 03:00:00+03', 2.11);
INSERT INTO public.hourly_price VALUES ('2023-08-05 04:00:00+03', 1.13);
INSERT INTO public.hourly_price VALUES ('2023-08-05 05:00:00+03', 0.85);
INSERT INTO public.hourly_price VALUES ('2023-08-05 06:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-08-05 07:00:00+03', 0.6);
INSERT INTO public.hourly_price VALUES ('2023-08-05 08:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-08-05 09:00:00+03', 0.93);
INSERT INTO public.hourly_price VALUES ('2023-08-05 10:00:00+03', 1.59);
INSERT INTO public.hourly_price VALUES ('2023-08-05 11:00:00+03', 1.88);
INSERT INTO public.hourly_price VALUES ('2023-08-05 12:00:00+03', 2);
INSERT INTO public.hourly_price VALUES ('2023-08-05 13:00:00+03', 2.1);
INSERT INTO public.hourly_price VALUES ('2023-08-05 14:00:00+03', 2.14);
INSERT INTO public.hourly_price VALUES ('2023-08-05 15:00:00+03', 2.1);
INSERT INTO public.hourly_price VALUES ('2023-08-05 16:00:00+03', 2.05);
INSERT INTO public.hourly_price VALUES ('2023-08-05 17:00:00+03', 2.03);
INSERT INTO public.hourly_price VALUES ('2023-08-05 18:00:00+03', 2.05);
INSERT INTO public.hourly_price VALUES ('2023-08-05 19:00:00+03', 2.09);
INSERT INTO public.hourly_price VALUES ('2023-08-05 20:00:00+03', 2.13);
INSERT INTO public.hourly_price VALUES ('2023-08-05 21:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-08-05 22:00:00+03', 2.29);
INSERT INTO public.hourly_price VALUES ('2023-08-05 23:00:00+03', 2.32);
INSERT INTO public.hourly_price VALUES ('2023-08-06 00:00:00+03', 2.25);
INSERT INTO public.hourly_price VALUES ('2023-08-06 01:00:00+03', 2.24);
INSERT INTO public.hourly_price VALUES ('2023-08-06 02:00:00+03', 2.2);
INSERT INTO public.hourly_price VALUES ('2023-08-06 03:00:00+03', 2.13);
INSERT INTO public.hourly_price VALUES ('2023-08-06 04:00:00+03', 1.88);
INSERT INTO public.hourly_price VALUES ('2023-08-06 05:00:00+03', 1.83);
INSERT INTO public.hourly_price VALUES ('2023-08-06 06:00:00+03', 1.67);
INSERT INTO public.hourly_price VALUES ('2023-08-06 07:00:00+03', 1.61);
INSERT INTO public.hourly_price VALUES ('2023-08-06 08:00:00+03', 1.48);
INSERT INTO public.hourly_price VALUES ('2023-08-06 09:00:00+03', 1.37);
INSERT INTO public.hourly_price VALUES ('2023-08-06 10:00:00+03', 1.36);
INSERT INTO public.hourly_price VALUES ('2023-08-06 11:00:00+03', 1.56);
INSERT INTO public.hourly_price VALUES ('2023-08-06 12:00:00+03', 1.98);
INSERT INTO public.hourly_price VALUES ('2023-08-06 13:00:00+03', 2.02);
INSERT INTO public.hourly_price VALUES ('2023-08-06 14:00:00+03', 2.07);
INSERT INTO public.hourly_price VALUES ('2023-08-06 15:00:00+03', 2.03);
INSERT INTO public.hourly_price VALUES ('2023-08-06 16:00:00+03', 2.01);
INSERT INTO public.hourly_price VALUES ('2023-08-06 17:00:00+03', 1.45);
INSERT INTO public.hourly_price VALUES ('2023-08-06 18:00:00+03', 1.48);
INSERT INTO public.hourly_price VALUES ('2023-08-06 19:00:00+03', 1.13);
INSERT INTO public.hourly_price VALUES ('2023-08-06 20:00:00+03', 1.46);
INSERT INTO public.hourly_price VALUES ('2023-08-06 21:00:00+03', 1.46);
INSERT INTO public.hourly_price VALUES ('2023-08-06 22:00:00+03', 1.37);
INSERT INTO public.hourly_price VALUES ('2023-08-06 23:00:00+03', 1.17);
INSERT INTO public.hourly_price VALUES ('2023-08-07 00:00:00+03', 0.57);
INSERT INTO public.hourly_price VALUES ('2023-08-07 01:00:00+03', 0.42);
INSERT INTO public.hourly_price VALUES ('2023-08-07 02:00:00+03', 0.16);
INSERT INTO public.hourly_price VALUES ('2023-08-07 03:00:00+03', -0.1);
INSERT INTO public.hourly_price VALUES ('2023-08-07 04:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-08-07 05:00:00+03', -0.12);
INSERT INTO public.hourly_price VALUES ('2023-08-07 06:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-08-07 07:00:00+03', -0.25);
INSERT INTO public.hourly_price VALUES ('2023-08-07 08:00:00+03', -0.24);
INSERT INTO public.hourly_price VALUES ('2023-08-07 09:00:00+03', -0.17);
INSERT INTO public.hourly_price VALUES ('2023-08-07 10:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-07 11:00:00+03', 0.29);
INSERT INTO public.hourly_price VALUES ('2023-08-07 12:00:00+03', 0.55);
INSERT INTO public.hourly_price VALUES ('2023-08-07 13:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-08-07 14:00:00+03', 0.5);
INSERT INTO public.hourly_price VALUES ('2023-08-07 15:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-08-07 16:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-07 17:00:00+03', -0.08);
INSERT INTO public.hourly_price VALUES ('2023-08-07 18:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-08-07 19:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-08-07 20:00:00+03', -0.09);
INSERT INTO public.hourly_price VALUES ('2023-08-07 21:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-07 22:00:00+03', 0.1);
INSERT INTO public.hourly_price VALUES ('2023-08-07 23:00:00+03', 0.36);
INSERT INTO public.hourly_price VALUES ('2023-08-08 00:00:00+03', 0.17);
INSERT INTO public.hourly_price VALUES ('2023-08-08 01:00:00+03', 0.09);
INSERT INTO public.hourly_price VALUES ('2023-08-08 02:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-08 03:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-08-08 04:00:00+03', -0.43);
INSERT INTO public.hourly_price VALUES ('2023-08-08 05:00:00+03', -0.6);
INSERT INTO public.hourly_price VALUES ('2023-08-08 06:00:00+03', -0.62);
INSERT INTO public.hourly_price VALUES ('2023-08-08 07:00:00+03', -0.59);
INSERT INTO public.hourly_price VALUES ('2023-08-08 08:00:00+03', -0.51);
INSERT INTO public.hourly_price VALUES ('2023-08-08 09:00:00+03', -0.34);
INSERT INTO public.hourly_price VALUES ('2023-08-08 10:00:00+03', -0.17);
INSERT INTO public.hourly_price VALUES ('2023-08-08 11:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-08-08 12:00:00+03', -0.06);
INSERT INTO public.hourly_price VALUES ('2023-08-08 13:00:00+03', -0.26);
INSERT INTO public.hourly_price VALUES ('2023-08-08 14:00:00+03', -0.52);
INSERT INTO public.hourly_price VALUES ('2023-08-08 15:00:00+03', -0.62);
INSERT INTO public.hourly_price VALUES ('2023-08-08 16:00:00+03', -0.62);
INSERT INTO public.hourly_price VALUES ('2023-08-08 17:00:00+03', -0.68);
INSERT INTO public.hourly_price VALUES ('2023-08-08 18:00:00+03', -1);
INSERT INTO public.hourly_price VALUES ('2023-08-08 19:00:00+03', -1.16);
INSERT INTO public.hourly_price VALUES ('2023-08-08 20:00:00+03', -0.57);
INSERT INTO public.hourly_price VALUES ('2023-08-08 21:00:00+03', -0.27);
INSERT INTO public.hourly_price VALUES ('2023-08-08 22:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-08-08 23:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-08-09 00:00:00+03', -0.25);
INSERT INTO public.hourly_price VALUES ('2023-08-09 01:00:00+03', -0.3);
INSERT INTO public.hourly_price VALUES ('2023-08-09 02:00:00+03', -0.42);
INSERT INTO public.hourly_price VALUES ('2023-08-09 03:00:00+03', -0.51);
INSERT INTO public.hourly_price VALUES ('2023-08-09 04:00:00+03', -0.54);
INSERT INTO public.hourly_price VALUES ('2023-08-09 05:00:00+03', -0.54);
INSERT INTO public.hourly_price VALUES ('2023-08-09 06:00:00+03', -0.61);
INSERT INTO public.hourly_price VALUES ('2023-08-09 07:00:00+03', -0.62);
INSERT INTO public.hourly_price VALUES ('2023-08-09 08:00:00+03', -0.52);
INSERT INTO public.hourly_price VALUES ('2023-08-09 09:00:00+03', -0.44);
INSERT INTO public.hourly_price VALUES ('2023-08-09 10:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-09 11:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-08-09 12:00:00+03', 0.45);
INSERT INTO public.hourly_price VALUES ('2023-08-09 13:00:00+03', 0.57);
INSERT INTO public.hourly_price VALUES ('2023-08-09 14:00:00+03', 0.77);
INSERT INTO public.hourly_price VALUES ('2023-08-09 15:00:00+03', 1.11);
INSERT INTO public.hourly_price VALUES ('2023-08-09 16:00:00+03', 0.84);
INSERT INTO public.hourly_price VALUES ('2023-08-09 17:00:00+03', 0.82);
INSERT INTO public.hourly_price VALUES ('2023-08-09 18:00:00+03', 0.83);
INSERT INTO public.hourly_price VALUES ('2023-08-09 19:00:00+03', 0.64);
INSERT INTO public.hourly_price VALUES ('2023-08-09 20:00:00+03', 0.71);
INSERT INTO public.hourly_price VALUES ('2023-08-09 21:00:00+03', 1.03);
INSERT INTO public.hourly_price VALUES ('2023-08-09 22:00:00+03', 1.86);
INSERT INTO public.hourly_price VALUES ('2023-08-09 23:00:00+03', 1.81);
INSERT INTO public.hourly_price VALUES ('2023-08-10 00:00:00+03', 1.25);
INSERT INTO public.hourly_price VALUES ('2023-08-10 01:00:00+03', 1.35);
INSERT INTO public.hourly_price VALUES ('2023-08-10 02:00:00+03', 1.2);
INSERT INTO public.hourly_price VALUES ('2023-08-10 03:00:00+03', 0.8);
INSERT INTO public.hourly_price VALUES ('2023-08-10 04:00:00+03', 0.76);
INSERT INTO public.hourly_price VALUES ('2023-08-10 05:00:00+03', 0.75);
INSERT INTO public.hourly_price VALUES ('2023-08-10 06:00:00+03', 0.72);
INSERT INTO public.hourly_price VALUES ('2023-08-10 07:00:00+03', 0.67);
INSERT INTO public.hourly_price VALUES ('2023-08-10 08:00:00+03', 0.75);
INSERT INTO public.hourly_price VALUES ('2023-08-10 09:00:00+03', 0.99);
INSERT INTO public.hourly_price VALUES ('2023-08-10 10:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-08-10 11:00:00+03', 2.14);
INSERT INTO public.hourly_price VALUES ('2023-08-10 12:00:00+03', 2.65);
INSERT INTO public.hourly_price VALUES ('2023-08-10 13:00:00+03', 2.89);
INSERT INTO public.hourly_price VALUES ('2023-08-10 14:00:00+03', 2.87);
INSERT INTO public.hourly_price VALUES ('2023-08-10 15:00:00+03', 2.84);
INSERT INTO public.hourly_price VALUES ('2023-08-10 16:00:00+03', 2.26);
INSERT INTO public.hourly_price VALUES ('2023-08-10 17:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-08-10 18:00:00+03', 2.09);
INSERT INTO public.hourly_price VALUES ('2023-08-10 19:00:00+03', 2.1);
INSERT INTO public.hourly_price VALUES ('2023-08-10 20:00:00+03', 2.18);
INSERT INTO public.hourly_price VALUES ('2023-08-10 21:00:00+03', 2.27);
INSERT INTO public.hourly_price VALUES ('2023-08-10 22:00:00+03', 2.32);
INSERT INTO public.hourly_price VALUES ('2023-08-10 23:00:00+03', 2.27);
INSERT INTO public.hourly_price VALUES ('2023-08-11 00:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-08-11 01:00:00+03', 2.1);
INSERT INTO public.hourly_price VALUES ('2023-08-11 02:00:00+03', 1.74);
INSERT INTO public.hourly_price VALUES ('2023-08-11 03:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-08-11 04:00:00+03', 1.7);
INSERT INTO public.hourly_price VALUES ('2023-08-11 05:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-08-11 06:00:00+03', 1.42);
INSERT INTO public.hourly_price VALUES ('2023-08-11 07:00:00+03', 1.32);
INSERT INTO public.hourly_price VALUES ('2023-08-11 08:00:00+03', 1.39);
INSERT INTO public.hourly_price VALUES ('2023-08-11 09:00:00+03', 1.66);
INSERT INTO public.hourly_price VALUES ('2023-08-11 10:00:00+03', 2.13);
INSERT INTO public.hourly_price VALUES ('2023-08-11 11:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-08-11 12:00:00+03', 2.89);
INSERT INTO public.hourly_price VALUES ('2023-08-11 13:00:00+03', 2.92);
INSERT INTO public.hourly_price VALUES ('2023-08-11 14:00:00+03', 2.65);
INSERT INTO public.hourly_price VALUES ('2023-08-11 15:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-08-11 16:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-08-11 17:00:00+03', 2.22);
INSERT INTO public.hourly_price VALUES ('2023-08-11 18:00:00+03', 2.3);
INSERT INTO public.hourly_price VALUES ('2023-08-11 19:00:00+03', 2.31);
INSERT INTO public.hourly_price VALUES ('2023-08-11 20:00:00+03', 2.36);
INSERT INTO public.hourly_price VALUES ('2023-08-11 21:00:00+03', 2.47);
INSERT INTO public.hourly_price VALUES ('2023-08-11 22:00:00+03', 2.83);
INSERT INTO public.hourly_price VALUES ('2023-08-11 23:00:00+03', 2.92);
INSERT INTO public.hourly_price VALUES ('2023-08-12 00:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-08-12 01:00:00+03', 2.27);
INSERT INTO public.hourly_price VALUES ('2023-08-12 02:00:00+03', 2.08);
INSERT INTO public.hourly_price VALUES ('2023-08-12 03:00:00+03', 1.75);
INSERT INTO public.hourly_price VALUES ('2023-08-12 04:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-08-12 05:00:00+03', 1.42);
INSERT INTO public.hourly_price VALUES ('2023-08-12 06:00:00+03', 1.27);
INSERT INTO public.hourly_price VALUES ('2023-08-12 07:00:00+03', 1.07);
INSERT INTO public.hourly_price VALUES ('2023-08-12 08:00:00+03', 0.93);
INSERT INTO public.hourly_price VALUES ('2023-08-12 09:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-08-12 10:00:00+03', 0.66);
INSERT INTO public.hourly_price VALUES ('2023-08-12 11:00:00+03', 1);
INSERT INTO public.hourly_price VALUES ('2023-08-12 12:00:00+03', 1.31);
INSERT INTO public.hourly_price VALUES ('2023-08-12 13:00:00+03', 1.59);
INSERT INTO public.hourly_price VALUES ('2023-08-12 14:00:00+03', 1.67);
INSERT INTO public.hourly_price VALUES ('2023-08-12 15:00:00+03', 1.48);
INSERT INTO public.hourly_price VALUES ('2023-08-12 16:00:00+03', 1.35);
INSERT INTO public.hourly_price VALUES ('2023-08-12 17:00:00+03', 1.25);
INSERT INTO public.hourly_price VALUES ('2023-08-12 18:00:00+03', 0.74);
INSERT INTO public.hourly_price VALUES ('2023-08-12 19:00:00+03', 0.86);
INSERT INTO public.hourly_price VALUES ('2023-08-12 20:00:00+03', 1.89);
INSERT INTO public.hourly_price VALUES ('2023-08-12 21:00:00+03', 2.16);
INSERT INTO public.hourly_price VALUES ('2023-08-12 22:00:00+03', 2.22);
INSERT INTO public.hourly_price VALUES ('2023-08-12 23:00:00+03', 2.22);
INSERT INTO public.hourly_price VALUES ('2023-08-13 00:00:00+03', 2.12);
INSERT INTO public.hourly_price VALUES ('2023-08-13 01:00:00+03', 2);
INSERT INTO public.hourly_price VALUES ('2023-08-13 02:00:00+03', 1.82);
INSERT INTO public.hourly_price VALUES ('2023-08-13 03:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-08-13 04:00:00+03', 1.26);
INSERT INTO public.hourly_price VALUES ('2023-08-13 05:00:00+03', 1.31);
INSERT INTO public.hourly_price VALUES ('2023-08-13 06:00:00+03', 1.33);
INSERT INTO public.hourly_price VALUES ('2023-08-13 07:00:00+03', 1.39);
INSERT INTO public.hourly_price VALUES ('2023-08-13 08:00:00+03', 1.46);
INSERT INTO public.hourly_price VALUES ('2023-08-13 09:00:00+03', 1.15);
INSERT INTO public.hourly_price VALUES ('2023-08-13 10:00:00+03', 1.3);
INSERT INTO public.hourly_price VALUES ('2023-08-13 11:00:00+03', 1.64);
INSERT INTO public.hourly_price VALUES ('2023-08-13 12:00:00+03', 1.97);
INSERT INTO public.hourly_price VALUES ('2023-08-13 13:00:00+03', 2.11);
INSERT INTO public.hourly_price VALUES ('2023-08-13 14:00:00+03', 1.96);
INSERT INTO public.hourly_price VALUES ('2023-08-13 15:00:00+03', 1.71);
INSERT INTO public.hourly_price VALUES ('2023-08-13 16:00:00+03', 0.75);
INSERT INTO public.hourly_price VALUES ('2023-08-13 17:00:00+03', 0.14);
INSERT INTO public.hourly_price VALUES ('2023-08-13 18:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-08-13 19:00:00+03', 0.86);
INSERT INTO public.hourly_price VALUES ('2023-08-13 20:00:00+03', 2.14);
INSERT INTO public.hourly_price VALUES ('2023-08-13 21:00:00+03', 2.39);
INSERT INTO public.hourly_price VALUES ('2023-08-13 22:00:00+03', 2.41);
INSERT INTO public.hourly_price VALUES ('2023-08-13 23:00:00+03', 2.42);
INSERT INTO public.hourly_price VALUES ('2023-08-14 00:00:00+03', 2.31);
INSERT INTO public.hourly_price VALUES ('2023-08-14 01:00:00+03', 2.25);
INSERT INTO public.hourly_price VALUES ('2023-08-14 02:00:00+03', 2.13);
INSERT INTO public.hourly_price VALUES ('2023-08-14 03:00:00+03', 1.76);
INSERT INTO public.hourly_price VALUES ('2023-08-14 04:00:00+03', 1.92);
INSERT INTO public.hourly_price VALUES ('2023-08-14 05:00:00+03', 1.81);
INSERT INTO public.hourly_price VALUES ('2023-08-14 06:00:00+03', 1.77);
INSERT INTO public.hourly_price VALUES ('2023-08-14 07:00:00+03', 1.76);
INSERT INTO public.hourly_price VALUES ('2023-08-14 08:00:00+03', 1.81);
INSERT INTO public.hourly_price VALUES ('2023-08-14 09:00:00+03', 1.99);
INSERT INTO public.hourly_price VALUES ('2023-08-14 10:00:00+03', 3.18);
INSERT INTO public.hourly_price VALUES ('2023-08-14 11:00:00+03', 12.86);
INSERT INTO public.hourly_price VALUES ('2023-08-14 12:00:00+03', 12.57);
INSERT INTO public.hourly_price VALUES ('2023-08-14 13:00:00+03', 11.08);
INSERT INTO public.hourly_price VALUES ('2023-08-14 14:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-14 15:00:00+03', 6.63);
INSERT INTO public.hourly_price VALUES ('2023-08-14 16:00:00+03', 3.4);
INSERT INTO public.hourly_price VALUES ('2023-08-14 17:00:00+03', 2.86);
INSERT INTO public.hourly_price VALUES ('2023-08-14 18:00:00+03', 2.78);
INSERT INTO public.hourly_price VALUES ('2023-08-14 19:00:00+03', 2.68);
INSERT INTO public.hourly_price VALUES ('2023-08-14 20:00:00+03', 2.85);
INSERT INTO public.hourly_price VALUES ('2023-08-14 21:00:00+03', 12.55);
INSERT INTO public.hourly_price VALUES ('2023-08-14 22:00:00+03', 5.55);
INSERT INTO public.hourly_price VALUES ('2023-08-14 23:00:00+03', 3.06);
INSERT INTO public.hourly_price VALUES ('2023-08-15 00:00:00+03', 3.05);
INSERT INTO public.hourly_price VALUES ('2023-08-15 01:00:00+03', 2.73);
INSERT INTO public.hourly_price VALUES ('2023-08-15 02:00:00+03', 2.27);
INSERT INTO public.hourly_price VALUES ('2023-08-15 03:00:00+03', 2.03);
INSERT INTO public.hourly_price VALUES ('2023-08-15 04:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-08-15 05:00:00+03', 0.31);
INSERT INTO public.hourly_price VALUES ('2023-08-15 06:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-08-15 07:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-08-15 08:00:00+03', 1.11);
INSERT INTO public.hourly_price VALUES ('2023-08-15 09:00:00+03', 2.15);
INSERT INTO public.hourly_price VALUES ('2023-08-15 10:00:00+03', 2.38);
INSERT INTO public.hourly_price VALUES ('2023-08-15 11:00:00+03', 3.32);
INSERT INTO public.hourly_price VALUES ('2023-08-15 12:00:00+03', 3.26);
INSERT INTO public.hourly_price VALUES ('2023-08-15 13:00:00+03', 3.46);
INSERT INTO public.hourly_price VALUES ('2023-08-15 14:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-08-15 15:00:00+03', 3.05);
INSERT INTO public.hourly_price VALUES ('2023-08-15 16:00:00+03', 2.96);
INSERT INTO public.hourly_price VALUES ('2023-08-15 17:00:00+03', 2.84);
INSERT INTO public.hourly_price VALUES ('2023-08-15 18:00:00+03', 2.85);
INSERT INTO public.hourly_price VALUES ('2023-08-15 19:00:00+03', 2.87);
INSERT INTO public.hourly_price VALUES ('2023-08-15 20:00:00+03', 3.02);
INSERT INTO public.hourly_price VALUES ('2023-08-15 21:00:00+03', 11.81);
INSERT INTO public.hourly_price VALUES ('2023-08-15 22:00:00+03', 13.36);
INSERT INTO public.hourly_price VALUES ('2023-08-15 23:00:00+03', 15.34);
INSERT INTO public.hourly_price VALUES ('2023-08-16 00:00:00+03', 3.05);
INSERT INTO public.hourly_price VALUES ('2023-08-16 01:00:00+03', 2.87);
INSERT INTO public.hourly_price VALUES ('2023-08-16 02:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-08-16 03:00:00+03', 2.18);
INSERT INTO public.hourly_price VALUES ('2023-08-16 04:00:00+03', 0.09);
INSERT INTO public.hourly_price VALUES ('2023-08-16 05:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-16 06:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-16 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-16 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-08-16 09:00:00+03', 0.47);
INSERT INTO public.hourly_price VALUES ('2023-08-16 10:00:00+03', 1.89);
INSERT INTO public.hourly_price VALUES ('2023-08-16 11:00:00+03', 2.12);
INSERT INTO public.hourly_price VALUES ('2023-08-16 12:00:00+03', 2.25);
INSERT INTO public.hourly_price VALUES ('2023-08-16 13:00:00+03', 2.39);
INSERT INTO public.hourly_price VALUES ('2023-08-16 14:00:00+03', 2.37);
INSERT INTO public.hourly_price VALUES ('2023-08-16 15:00:00+03', 2.3);
INSERT INTO public.hourly_price VALUES ('2023-08-16 16:00:00+03', 2.24);
INSERT INTO public.hourly_price VALUES ('2023-08-16 17:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-08-16 18:00:00+03', 2.23);
INSERT INTO public.hourly_price VALUES ('2023-08-16 19:00:00+03', 2.21);
INSERT INTO public.hourly_price VALUES ('2023-08-16 20:00:00+03', 2.22);
INSERT INTO public.hourly_price VALUES ('2023-08-16 21:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-08-16 22:00:00+03', 3.51);
INSERT INTO public.hourly_price VALUES ('2023-08-16 23:00:00+03', 2.47);
INSERT INTO public.hourly_price VALUES ('2023-08-17 00:00:00+03', 2.59);
INSERT INTO public.hourly_price VALUES ('2023-08-17 01:00:00+03', 2.11);
INSERT INTO public.hourly_price VALUES ('2023-08-17 02:00:00+03', 1.72);
INSERT INTO public.hourly_price VALUES ('2023-08-17 03:00:00+03', 0.89);
INSERT INTO public.hourly_price VALUES ('2023-08-17 04:00:00+03', 0.1);
INSERT INTO public.hourly_price VALUES ('2023-08-17 05:00:00+03', 0.12);
INSERT INTO public.hourly_price VALUES ('2023-08-17 06:00:00+03', 0.23);
INSERT INTO public.hourly_price VALUES ('2023-08-17 07:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-08-17 08:00:00+03', 0.46);
INSERT INTO public.hourly_price VALUES ('2023-08-17 09:00:00+03', 0.87);
INSERT INTO public.hourly_price VALUES ('2023-08-17 10:00:00+03', 3.23);
INSERT INTO public.hourly_price VALUES ('2023-08-17 11:00:00+03', 4.96);
INSERT INTO public.hourly_price VALUES ('2023-08-17 12:00:00+03', 2.29);
INSERT INTO public.hourly_price VALUES ('2023-08-17 13:00:00+03', 2.34);
INSERT INTO public.hourly_price VALUES ('2023-08-17 14:00:00+03', 2.4);
INSERT INTO public.hourly_price VALUES ('2023-08-17 15:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-08-17 16:00:00+03', 2.3);
INSERT INTO public.hourly_price VALUES ('2023-08-17 17:00:00+03', 2.28);
INSERT INTO public.hourly_price VALUES ('2023-08-17 18:00:00+03', 2.31);
INSERT INTO public.hourly_price VALUES ('2023-08-17 19:00:00+03', 2.31);
INSERT INTO public.hourly_price VALUES ('2023-08-17 20:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-08-17 21:00:00+03', 3.03);
INSERT INTO public.hourly_price VALUES ('2023-08-17 22:00:00+03', 3.34);
INSERT INTO public.hourly_price VALUES ('2023-08-17 23:00:00+03', 3.1);
INSERT INTO public.hourly_price VALUES ('2023-08-18 00:00:00+03', 3.23);
INSERT INTO public.hourly_price VALUES ('2023-08-18 01:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-08-18 02:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-08-18 03:00:00+03', 2.19);
INSERT INTO public.hourly_price VALUES ('2023-08-18 04:00:00+03', 2.24);
INSERT INTO public.hourly_price VALUES ('2023-08-18 05:00:00+03', 2.18);
INSERT INTO public.hourly_price VALUES ('2023-08-18 06:00:00+03', 2.12);
INSERT INTO public.hourly_price VALUES ('2023-08-18 07:00:00+03', 2.01);
INSERT INTO public.hourly_price VALUES ('2023-08-18 08:00:00+03', 2.04);
INSERT INTO public.hourly_price VALUES ('2023-08-18 09:00:00+03', 2.62);
INSERT INTO public.hourly_price VALUES ('2023-08-18 10:00:00+03', 14.8);
INSERT INTO public.hourly_price VALUES ('2023-08-18 11:00:00+03', 25.86);
INSERT INTO public.hourly_price VALUES ('2023-08-18 12:00:00+03', 33.54);
INSERT INTO public.hourly_price VALUES ('2023-08-18 13:00:00+03', 23.31);
INSERT INTO public.hourly_price VALUES ('2023-08-18 14:00:00+03', 18.34);
INSERT INTO public.hourly_price VALUES ('2023-08-18 15:00:00+03', 16.74);
INSERT INTO public.hourly_price VALUES ('2023-08-18 16:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-08-18 17:00:00+03', 18.55);
INSERT INTO public.hourly_price VALUES ('2023-08-18 18:00:00+03', 11.1);
INSERT INTO public.hourly_price VALUES ('2023-08-18 19:00:00+03', 11.82);
INSERT INTO public.hourly_price VALUES ('2023-08-18 20:00:00+03', 16.74);
INSERT INTO public.hourly_price VALUES ('2023-08-18 21:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-08-18 22:00:00+03', 24.8);
INSERT INTO public.hourly_price VALUES ('2023-08-18 23:00:00+03', 23.13);
INSERT INTO public.hourly_price VALUES ('2023-08-19 00:00:00+03', 19.26);
INSERT INTO public.hourly_price VALUES ('2023-08-19 01:00:00+03', 15.8);
INSERT INTO public.hourly_price VALUES ('2023-08-19 02:00:00+03', 1.94);
INSERT INTO public.hourly_price VALUES ('2023-08-19 03:00:00+03', 1.78);
INSERT INTO public.hourly_price VALUES ('2023-08-19 04:00:00+03', 12.86);
INSERT INTO public.hourly_price VALUES ('2023-08-19 05:00:00+03', 8.01);
INSERT INTO public.hourly_price VALUES ('2023-08-19 06:00:00+03', 7.94);
INSERT INTO public.hourly_price VALUES ('2023-08-19 07:00:00+03', 9.18);
INSERT INTO public.hourly_price VALUES ('2023-08-19 08:00:00+03', 11.56);
INSERT INTO public.hourly_price VALUES ('2023-08-19 09:00:00+03', 12.66);
INSERT INTO public.hourly_price VALUES ('2023-08-19 10:00:00+03', 12.99);
INSERT INTO public.hourly_price VALUES ('2023-08-19 11:00:00+03', 14.63);
INSERT INTO public.hourly_price VALUES ('2023-08-19 12:00:00+03', 14.99);
INSERT INTO public.hourly_price VALUES ('2023-08-19 13:00:00+03', 18.6);
INSERT INTO public.hourly_price VALUES ('2023-08-19 14:00:00+03', 26.33);
INSERT INTO public.hourly_price VALUES ('2023-08-19 15:00:00+03', 14.53);
INSERT INTO public.hourly_price VALUES ('2023-08-19 16:00:00+03', 12.68);
INSERT INTO public.hourly_price VALUES ('2023-08-19 17:00:00+03', 16.17);
INSERT INTO public.hourly_price VALUES ('2023-08-19 18:00:00+03', 15.62);
INSERT INTO public.hourly_price VALUES ('2023-08-19 19:00:00+03', 16.51);
INSERT INTO public.hourly_price VALUES ('2023-08-19 20:00:00+03', 18.6);
INSERT INTO public.hourly_price VALUES ('2023-08-19 21:00:00+03', 16.62);
INSERT INTO public.hourly_price VALUES ('2023-08-19 22:00:00+03', 20.6);
INSERT INTO public.hourly_price VALUES ('2023-08-19 23:00:00+03', 23.21);
INSERT INTO public.hourly_price VALUES ('2023-08-20 00:00:00+03', 16.71);
INSERT INTO public.hourly_price VALUES ('2023-08-20 01:00:00+03', 17.26);
INSERT INTO public.hourly_price VALUES ('2023-08-20 02:00:00+03', 15.34);
INSERT INTO public.hourly_price VALUES ('2023-08-20 03:00:00+03', 5.04);
INSERT INTO public.hourly_price VALUES ('2023-08-20 04:00:00+03', 6.23);
INSERT INTO public.hourly_price VALUES ('2023-08-20 05:00:00+03', 4.57);
INSERT INTO public.hourly_price VALUES ('2023-08-20 06:00:00+03', 4.96);
INSERT INTO public.hourly_price VALUES ('2023-08-20 07:00:00+03', 3.3);
INSERT INTO public.hourly_price VALUES ('2023-08-20 08:00:00+03', 3.53);
INSERT INTO public.hourly_price VALUES ('2023-08-20 09:00:00+03', 4.75);
INSERT INTO public.hourly_price VALUES ('2023-08-20 10:00:00+03', 3.85);
INSERT INTO public.hourly_price VALUES ('2023-08-20 11:00:00+03', 9.2);
INSERT INTO public.hourly_price VALUES ('2023-08-20 12:00:00+03', 12.27);
INSERT INTO public.hourly_price VALUES ('2023-08-20 13:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-08-20 14:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-08-20 15:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-08-20 16:00:00+03', 9.9);
INSERT INTO public.hourly_price VALUES ('2023-08-20 17:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-08-20 18:00:00+03', 12.26);
INSERT INTO public.hourly_price VALUES ('2023-08-20 19:00:00+03', 9.08);
INSERT INTO public.hourly_price VALUES ('2023-08-20 20:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-08-20 21:00:00+03', 18.59);
INSERT INTO public.hourly_price VALUES ('2023-08-20 22:00:00+03', 24.77);
INSERT INTO public.hourly_price VALUES ('2023-08-20 23:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-08-21 00:00:00+03', 24.92);
INSERT INTO public.hourly_price VALUES ('2023-08-21 01:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-08-21 02:00:00+03', 15.71);
INSERT INTO public.hourly_price VALUES ('2023-08-21 03:00:00+03', 12.4);
INSERT INTO public.hourly_price VALUES ('2023-08-21 04:00:00+03', 13.88);
INSERT INTO public.hourly_price VALUES ('2023-08-21 05:00:00+03', 12.61);
INSERT INTO public.hourly_price VALUES ('2023-08-21 06:00:00+03', 12.24);
INSERT INTO public.hourly_price VALUES ('2023-08-21 07:00:00+03', 11.79);
INSERT INTO public.hourly_price VALUES ('2023-08-21 08:00:00+03', 12.08);
INSERT INTO public.hourly_price VALUES ('2023-08-21 09:00:00+03', 14.62);
INSERT INTO public.hourly_price VALUES ('2023-08-21 10:00:00+03', 43.4);
INSERT INTO public.hourly_price VALUES ('2023-08-21 11:00:00+03', 40.31);
INSERT INTO public.hourly_price VALUES ('2023-08-21 12:00:00+03', 68.19);
INSERT INTO public.hourly_price VALUES ('2023-08-21 13:00:00+03', 31.01);
INSERT INTO public.hourly_price VALUES ('2023-08-21 14:00:00+03', 59.89);
INSERT INTO public.hourly_price VALUES ('2023-08-21 15:00:00+03', 31.01);
INSERT INTO public.hourly_price VALUES ('2023-08-21 16:00:00+03', 31.01);
INSERT INTO public.hourly_price VALUES ('2023-08-21 17:00:00+03', 31.01);
INSERT INTO public.hourly_price VALUES ('2023-08-21 18:00:00+03', 42.65);
INSERT INTO public.hourly_price VALUES ('2023-08-21 19:00:00+03', 37.2);
INSERT INTO public.hourly_price VALUES ('2023-08-21 20:00:00+03', 18.6);
INSERT INTO public.hourly_price VALUES ('2023-08-21 21:00:00+03', 37.2);
INSERT INTO public.hourly_price VALUES ('2023-08-21 22:00:00+03', 68.19);
INSERT INTO public.hourly_price VALUES ('2023-08-21 23:00:00+03', 31.01);
INSERT INTO public.hourly_price VALUES ('2023-08-22 00:00:00+03', 25.34);
INSERT INTO public.hourly_price VALUES ('2023-08-22 01:00:00+03', 20.96);
INSERT INTO public.hourly_price VALUES ('2023-08-22 02:00:00+03', 16.87);
INSERT INTO public.hourly_price VALUES ('2023-08-22 03:00:00+03', 14.26);
INSERT INTO public.hourly_price VALUES ('2023-08-22 04:00:00+03', 14.1);
INSERT INTO public.hourly_price VALUES ('2023-08-22 05:00:00+03', 13.01);
INSERT INTO public.hourly_price VALUES ('2023-08-22 06:00:00+03', 12.83);
INSERT INTO public.hourly_price VALUES ('2023-08-22 07:00:00+03', 12.83);
INSERT INTO public.hourly_price VALUES ('2023-08-22 08:00:00+03', 13.12);
INSERT INTO public.hourly_price VALUES ('2023-08-22 09:00:00+03', 17.37);
INSERT INTO public.hourly_price VALUES ('2023-08-22 10:00:00+03', 20.04);
INSERT INTO public.hourly_price VALUES ('2023-08-22 11:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-08-22 12:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-08-22 13:00:00+03', 28.7);
INSERT INTO public.hourly_price VALUES ('2023-08-22 14:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-08-22 15:00:00+03', 49.78);
INSERT INTO public.hourly_price VALUES ('2023-08-22 16:00:00+03', 29.76);
INSERT INTO public.hourly_price VALUES ('2023-08-22 17:00:00+03', 15.37);
INSERT INTO public.hourly_price VALUES ('2023-08-22 18:00:00+03', 13.03);
INSERT INTO public.hourly_price VALUES ('2023-08-22 19:00:00+03', 12.85);
INSERT INTO public.hourly_price VALUES ('2023-08-22 20:00:00+03', 18.6);
INSERT INTO public.hourly_price VALUES ('2023-08-22 21:00:00+03', 19.73);
INSERT INTO public.hourly_price VALUES ('2023-08-22 22:00:00+03', 21.09);
INSERT INTO public.hourly_price VALUES ('2023-08-22 23:00:00+03', 25.08);
INSERT INTO public.hourly_price VALUES ('2023-08-23 00:00:00+03', 26.34);
INSERT INTO public.hourly_price VALUES ('2023-08-23 01:00:00+03', 21.38);
INSERT INTO public.hourly_price VALUES ('2023-08-23 02:00:00+03', 18.08);
INSERT INTO public.hourly_price VALUES ('2023-08-23 03:00:00+03', 9.93);
INSERT INTO public.hourly_price VALUES ('2023-08-23 04:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-23 05:00:00+03', 11.78);
INSERT INTO public.hourly_price VALUES ('2023-08-23 06:00:00+03', 12.03);
INSERT INTO public.hourly_price VALUES ('2023-08-23 07:00:00+03', 12.96);
INSERT INTO public.hourly_price VALUES ('2023-08-23 08:00:00+03', 13.66);
INSERT INTO public.hourly_price VALUES ('2023-08-23 09:00:00+03', 14.29);
INSERT INTO public.hourly_price VALUES ('2023-08-23 10:00:00+03', 17.48);
INSERT INTO public.hourly_price VALUES ('2023-08-23 11:00:00+03', 20.08);
INSERT INTO public.hourly_price VALUES ('2023-08-23 12:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-23 13:00:00+03', 21.2);
INSERT INTO public.hourly_price VALUES ('2023-08-23 14:00:00+03', 18.6);
INSERT INTO public.hourly_price VALUES ('2023-08-23 15:00:00+03', 21.08);
INSERT INTO public.hourly_price VALUES ('2023-08-23 16:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-23 17:00:00+03', 16.55);
INSERT INTO public.hourly_price VALUES ('2023-08-23 18:00:00+03', 18.59);
INSERT INTO public.hourly_price VALUES ('2023-08-23 19:00:00+03', 15.27);
INSERT INTO public.hourly_price VALUES ('2023-08-23 20:00:00+03', 16.87);
INSERT INTO public.hourly_price VALUES ('2023-08-23 21:00:00+03', 19.73);
INSERT INTO public.hourly_price VALUES ('2023-08-23 22:00:00+03', 27.96);
INSERT INTO public.hourly_price VALUES ('2023-08-23 23:00:00+03', 31.01);
INSERT INTO public.hourly_price VALUES ('2023-08-24 00:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-24 01:00:00+03', 23.56);
INSERT INTO public.hourly_price VALUES ('2023-08-24 02:00:00+03', 17.32);
INSERT INTO public.hourly_price VALUES ('2023-08-24 03:00:00+03', 9.52);
INSERT INTO public.hourly_price VALUES ('2023-08-24 04:00:00+03', 12.77);
INSERT INTO public.hourly_price VALUES ('2023-08-24 05:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-24 06:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-24 07:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-24 08:00:00+03', 14.87);
INSERT INTO public.hourly_price VALUES ('2023-08-24 09:00:00+03', 16.48);
INSERT INTO public.hourly_price VALUES ('2023-08-24 10:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-24 11:00:00+03', 21.14);
INSERT INTO public.hourly_price VALUES ('2023-08-24 12:00:00+03', 21.98);
INSERT INTO public.hourly_price VALUES ('2023-08-24 13:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-24 14:00:00+03', 19.83);
INSERT INTO public.hourly_price VALUES ('2023-08-24 15:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-24 16:00:00+03', 19.99);
INSERT INTO public.hourly_price VALUES ('2023-08-24 17:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-24 18:00:00+03', 20.25);
INSERT INTO public.hourly_price VALUES ('2023-08-24 19:00:00+03', 15.69);
INSERT INTO public.hourly_price VALUES ('2023-08-24 20:00:00+03', 19.54);
INSERT INTO public.hourly_price VALUES ('2023-08-24 21:00:00+03', 19.24);
INSERT INTO public.hourly_price VALUES ('2023-08-24 22:00:00+03', 25.63);
INSERT INTO public.hourly_price VALUES ('2023-08-24 23:00:00+03', 32.06);
INSERT INTO public.hourly_price VALUES ('2023-08-25 00:00:00+03', 25.54);
INSERT INTO public.hourly_price VALUES ('2023-08-25 01:00:00+03', 19.23);
INSERT INTO public.hourly_price VALUES ('2023-08-25 02:00:00+03', 19.28);
INSERT INTO public.hourly_price VALUES ('2023-08-25 03:00:00+03', 10.34);
INSERT INTO public.hourly_price VALUES ('2023-08-25 04:00:00+03', 10.37);
INSERT INTO public.hourly_price VALUES ('2023-08-25 05:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-25 06:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-25 07:00:00+03', 10.16);
INSERT INTO public.hourly_price VALUES ('2023-08-25 08:00:00+03', 11.48);
INSERT INTO public.hourly_price VALUES ('2023-08-25 09:00:00+03', 13.2);
INSERT INTO public.hourly_price VALUES ('2023-08-25 10:00:00+03', 19.26);
INSERT INTO public.hourly_price VALUES ('2023-08-25 11:00:00+03', 17.99);
INSERT INTO public.hourly_price VALUES ('2023-08-25 12:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-08-25 13:00:00+03', 22.32);
INSERT INTO public.hourly_price VALUES ('2023-08-25 14:00:00+03', 17.99);
INSERT INTO public.hourly_price VALUES ('2023-08-25 15:00:00+03', 19.23);
INSERT INTO public.hourly_price VALUES ('2023-08-25 16:00:00+03', 25.39);
INSERT INTO public.hourly_price VALUES ('2023-08-25 17:00:00+03', 24.77);
INSERT INTO public.hourly_price VALUES ('2023-08-25 18:00:00+03', 21.07);
INSERT INTO public.hourly_price VALUES ('2023-08-25 19:00:00+03', 14.87);
INSERT INTO public.hourly_price VALUES ('2023-08-25 20:00:00+03', 17.33);
INSERT INTO public.hourly_price VALUES ('2023-08-25 21:00:00+03', 20.14);
INSERT INTO public.hourly_price VALUES ('2023-08-25 22:00:00+03', 25.45);
INSERT INTO public.hourly_price VALUES ('2023-08-25 23:00:00+03', 22.51);
INSERT INTO public.hourly_price VALUES ('2023-08-26 00:00:00+03', 18.94);
INSERT INTO public.hourly_price VALUES ('2023-08-26 01:00:00+03', 22.18);
INSERT INTO public.hourly_price VALUES ('2023-08-26 02:00:00+03', 16.89);
INSERT INTO public.hourly_price VALUES ('2023-08-26 03:00:00+03', 5.53);
INSERT INTO public.hourly_price VALUES ('2023-08-26 04:00:00+03', 10.02);
INSERT INTO public.hourly_price VALUES ('2023-08-26 05:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-26 06:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-26 07:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-26 08:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-26 09:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-26 10:00:00+03', 9.05);
INSERT INTO public.hourly_price VALUES ('2023-08-26 11:00:00+03', 11.79);
INSERT INTO public.hourly_price VALUES ('2023-08-26 12:00:00+03', 12.19);
INSERT INTO public.hourly_price VALUES ('2023-08-26 13:00:00+03', 13.67);
INSERT INTO public.hourly_price VALUES ('2023-08-26 14:00:00+03', 11.29);
INSERT INTO public.hourly_price VALUES ('2023-08-26 15:00:00+03', 9.98);
INSERT INTO public.hourly_price VALUES ('2023-08-26 16:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-26 17:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-26 18:00:00+03', 11.16);
INSERT INTO public.hourly_price VALUES ('2023-08-26 19:00:00+03', 10.86);
INSERT INTO public.hourly_price VALUES ('2023-08-26 20:00:00+03', 12.91);
INSERT INTO public.hourly_price VALUES ('2023-08-26 21:00:00+03', 18.08);
INSERT INTO public.hourly_price VALUES ('2023-08-26 22:00:00+03', 21.03);
INSERT INTO public.hourly_price VALUES ('2023-08-26 23:00:00+03', 15.48);
INSERT INTO public.hourly_price VALUES ('2023-08-27 00:00:00+03', 14.25);
INSERT INTO public.hourly_price VALUES ('2023-08-27 01:00:00+03', 14.4);
INSERT INTO public.hourly_price VALUES ('2023-08-27 02:00:00+03', 8.95);
INSERT INTO public.hourly_price VALUES ('2023-08-27 03:00:00+03', 2.36);
INSERT INTO public.hourly_price VALUES ('2023-08-27 04:00:00+03', 4.96);
INSERT INTO public.hourly_price VALUES ('2023-08-27 05:00:00+03', 3.24);
INSERT INTO public.hourly_price VALUES ('2023-08-27 06:00:00+03', 2.87);
INSERT INTO public.hourly_price VALUES ('2023-08-27 07:00:00+03', 2.67);
INSERT INTO public.hourly_price VALUES ('2023-08-27 08:00:00+03', 2.37);
INSERT INTO public.hourly_price VALUES ('2023-08-27 09:00:00+03', 3.01);
INSERT INTO public.hourly_price VALUES ('2023-08-27 10:00:00+03', 3.69);
INSERT INTO public.hourly_price VALUES ('2023-08-27 11:00:00+03', 6.29);
INSERT INTO public.hourly_price VALUES ('2023-08-27 12:00:00+03', 11.67);
INSERT INTO public.hourly_price VALUES ('2023-08-27 13:00:00+03', 11.77);
INSERT INTO public.hourly_price VALUES ('2023-08-27 14:00:00+03', 11.58);
INSERT INTO public.hourly_price VALUES ('2023-08-27 15:00:00+03', 11.05);
INSERT INTO public.hourly_price VALUES ('2023-08-27 16:00:00+03', 7.57);
INSERT INTO public.hourly_price VALUES ('2023-08-27 17:00:00+03', 10.49);
INSERT INTO public.hourly_price VALUES ('2023-08-27 18:00:00+03', 10.61);
INSERT INTO public.hourly_price VALUES ('2023-08-27 19:00:00+03', 12.05);
INSERT INTO public.hourly_price VALUES ('2023-08-27 20:00:00+03', 12.15);
INSERT INTO public.hourly_price VALUES ('2023-08-27 21:00:00+03', 14.87);
INSERT INTO public.hourly_price VALUES ('2023-08-27 22:00:00+03', 15.38);
INSERT INTO public.hourly_price VALUES ('2023-08-27 23:00:00+03', 15.63);
INSERT INTO public.hourly_price VALUES ('2023-08-28 00:00:00+03', 15.14);
INSERT INTO public.hourly_price VALUES ('2023-08-28 01:00:00+03', 15.39);
INSERT INTO public.hourly_price VALUES ('2023-08-28 02:00:00+03', 4.96);
INSERT INTO public.hourly_price VALUES ('2023-08-28 03:00:00+03', 2.89);
INSERT INTO public.hourly_price VALUES ('2023-08-28 04:00:00+03', 7.72);
INSERT INTO public.hourly_price VALUES ('2023-08-28 05:00:00+03', 4.25);
INSERT INTO public.hourly_price VALUES ('2023-08-28 06:00:00+03', 3.43);
INSERT INTO public.hourly_price VALUES ('2023-08-28 07:00:00+03', 3.18);
INSERT INTO public.hourly_price VALUES ('2023-08-28 08:00:00+03', 3.65);
INSERT INTO public.hourly_price VALUES ('2023-08-28 09:00:00+03', 11.3);
INSERT INTO public.hourly_price VALUES ('2023-08-28 10:00:00+03', 13.79);
INSERT INTO public.hourly_price VALUES ('2023-08-28 11:00:00+03', 17.58);
INSERT INTO public.hourly_price VALUES ('2023-08-28 12:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-28 13:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-28 14:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-28 15:00:00+03', 18.57);
INSERT INTO public.hourly_price VALUES ('2023-08-28 16:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-28 17:00:00+03', 15.59);
INSERT INTO public.hourly_price VALUES ('2023-08-28 18:00:00+03', 14.33);
INSERT INTO public.hourly_price VALUES ('2023-08-28 19:00:00+03', 15.11);
INSERT INTO public.hourly_price VALUES ('2023-08-28 20:00:00+03', 20.42);
INSERT INTO public.hourly_price VALUES ('2023-08-28 21:00:00+03', 18.61);
INSERT INTO public.hourly_price VALUES ('2023-08-28 22:00:00+03', 20.19);
INSERT INTO public.hourly_price VALUES ('2023-08-28 23:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-29 00:00:00+03', 20.67);
INSERT INTO public.hourly_price VALUES ('2023-08-29 01:00:00+03', 17.23);
INSERT INTO public.hourly_price VALUES ('2023-08-29 02:00:00+03', 4.95);
INSERT INTO public.hourly_price VALUES ('2023-08-29 03:00:00+03', 3.42);
INSERT INTO public.hourly_price VALUES ('2023-08-29 04:00:00+03', 2);
INSERT INTO public.hourly_price VALUES ('2023-08-29 05:00:00+03', 1.87);
INSERT INTO public.hourly_price VALUES ('2023-08-29 06:00:00+03', 1.79);
INSERT INTO public.hourly_price VALUES ('2023-08-29 07:00:00+03', 1.8);
INSERT INTO public.hourly_price VALUES ('2023-08-29 08:00:00+03', 1.89);
INSERT INTO public.hourly_price VALUES ('2023-08-29 09:00:00+03', 2.94);
INSERT INTO public.hourly_price VALUES ('2023-08-29 10:00:00+03', 3.52);
INSERT INTO public.hourly_price VALUES ('2023-08-29 11:00:00+03', 4.15);
INSERT INTO public.hourly_price VALUES ('2023-08-29 12:00:00+03', 11.83);
INSERT INTO public.hourly_price VALUES ('2023-08-29 13:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-29 14:00:00+03', 8.67);
INSERT INTO public.hourly_price VALUES ('2023-08-29 15:00:00+03', 12.55);
INSERT INTO public.hourly_price VALUES ('2023-08-29 16:00:00+03', 9.95);
INSERT INTO public.hourly_price VALUES ('2023-08-29 17:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-08-29 18:00:00+03', 8.68);
INSERT INTO public.hourly_price VALUES ('2023-08-29 19:00:00+03', 7.57);
INSERT INTO public.hourly_price VALUES ('2023-08-29 20:00:00+03', 10.51);
INSERT INTO public.hourly_price VALUES ('2023-08-29 21:00:00+03', 17.14);
INSERT INTO public.hourly_price VALUES ('2023-08-29 22:00:00+03', 19.33);
INSERT INTO public.hourly_price VALUES ('2023-08-29 23:00:00+03', 21.08);
INSERT INTO public.hourly_price VALUES ('2023-08-30 00:00:00+03', 19.67);
INSERT INTO public.hourly_price VALUES ('2023-08-30 01:00:00+03', 13.88);
INSERT INTO public.hourly_price VALUES ('2023-08-30 02:00:00+03', 3.61);
INSERT INTO public.hourly_price VALUES ('2023-08-30 03:00:00+03', 3.35);
INSERT INTO public.hourly_price VALUES ('2023-08-30 04:00:00+03', 5.7);
INSERT INTO public.hourly_price VALUES ('2023-08-30 05:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-08-30 06:00:00+03', 4.23);
INSERT INTO public.hourly_price VALUES ('2023-08-30 07:00:00+03', 4.72);
INSERT INTO public.hourly_price VALUES ('2023-08-30 08:00:00+03', 7.44);
INSERT INTO public.hourly_price VALUES ('2023-08-30 09:00:00+03', 11.82);
INSERT INTO public.hourly_price VALUES ('2023-08-30 10:00:00+03', 15.77);
INSERT INTO public.hourly_price VALUES ('2023-08-30 11:00:00+03', 17.87);
INSERT INTO public.hourly_price VALUES ('2023-08-30 12:00:00+03', 21.08);
INSERT INTO public.hourly_price VALUES ('2023-08-30 13:00:00+03', 20.06);
INSERT INTO public.hourly_price VALUES ('2023-08-30 14:00:00+03', 19.84);
INSERT INTO public.hourly_price VALUES ('2023-08-30 15:00:00+03', 17.25);
INSERT INTO public.hourly_price VALUES ('2023-08-30 16:00:00+03', 18.24);
INSERT INTO public.hourly_price VALUES ('2023-08-30 17:00:00+03', 18.24);
INSERT INTO public.hourly_price VALUES ('2023-08-30 18:00:00+03', 19.77);
INSERT INTO public.hourly_price VALUES ('2023-08-30 19:00:00+03', 18.23);
INSERT INTO public.hourly_price VALUES ('2023-08-30 20:00:00+03', 20.47);
INSERT INTO public.hourly_price VALUES ('2023-08-30 21:00:00+03', 17.75);
INSERT INTO public.hourly_price VALUES ('2023-08-30 22:00:00+03', 17.87);
INSERT INTO public.hourly_price VALUES ('2023-08-30 23:00:00+03', 22.6);
INSERT INTO public.hourly_price VALUES ('2023-08-31 00:00:00+03', 20.84);
INSERT INTO public.hourly_price VALUES ('2023-08-31 01:00:00+03', 16.67);
INSERT INTO public.hourly_price VALUES ('2023-08-31 02:00:00+03', 14.46);
INSERT INTO public.hourly_price VALUES ('2023-08-31 03:00:00+03', 11.29);
INSERT INTO public.hourly_price VALUES ('2023-08-31 04:00:00+03', 11.24);
INSERT INTO public.hourly_price VALUES ('2023-08-31 05:00:00+03', 6.07);
INSERT INTO public.hourly_price VALUES ('2023-08-31 06:00:00+03', 4.45);
INSERT INTO public.hourly_price VALUES ('2023-08-31 07:00:00+03', 4.26);
INSERT INTO public.hourly_price VALUES ('2023-08-31 08:00:00+03', 4.39);
INSERT INTO public.hourly_price VALUES ('2023-08-31 09:00:00+03', 11.07);
INSERT INTO public.hourly_price VALUES ('2023-08-31 10:00:00+03', 13.07);
INSERT INTO public.hourly_price VALUES ('2023-08-31 11:00:00+03', 18.59);
INSERT INTO public.hourly_price VALUES ('2023-08-31 12:00:00+03', 19.69);
INSERT INTO public.hourly_price VALUES ('2023-08-31 13:00:00+03', 17.47);
INSERT INTO public.hourly_price VALUES ('2023-08-31 14:00:00+03', 19.21);
INSERT INTO public.hourly_price VALUES ('2023-08-31 15:00:00+03', 21.7);
INSERT INTO public.hourly_price VALUES ('2023-08-31 16:00:00+03', 20.78);
INSERT INTO public.hourly_price VALUES ('2023-08-31 17:00:00+03', 16.59);
INSERT INTO public.hourly_price VALUES ('2023-08-31 18:00:00+03', 12.81);
INSERT INTO public.hourly_price VALUES ('2023-08-31 19:00:00+03', 12.77);
INSERT INTO public.hourly_price VALUES ('2023-08-31 20:00:00+03', 14.31);
INSERT INTO public.hourly_price VALUES ('2023-08-31 21:00:00+03', 17.06);
INSERT INTO public.hourly_price VALUES ('2023-08-31 22:00:00+03', 19.44);
INSERT INTO public.hourly_price VALUES ('2023-08-31 23:00:00+03', 18.6);
INSERT INTO public.hourly_price VALUES ('2023-09-01 00:00:00+03', 17.25);
INSERT INTO public.hourly_price VALUES ('2023-09-01 01:00:00+03', 15.56);
INSERT INTO public.hourly_price VALUES ('2023-09-01 02:00:00+03', 12.89);
INSERT INTO public.hourly_price VALUES ('2023-09-01 03:00:00+03', 11.66);
INSERT INTO public.hourly_price VALUES ('2023-09-01 04:00:00+03', 2.5);
INSERT INTO public.hourly_price VALUES ('2023-09-01 05:00:00+03', 2.45);
INSERT INTO public.hourly_price VALUES ('2023-09-01 06:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-09-01 07:00:00+03', 2.34);
INSERT INTO public.hourly_price VALUES ('2023-09-01 08:00:00+03', 3.41);
INSERT INTO public.hourly_price VALUES ('2023-09-01 09:00:00+03', 9.31);
INSERT INTO public.hourly_price VALUES ('2023-09-01 10:00:00+03', 13.9);
INSERT INTO public.hourly_price VALUES ('2023-09-01 11:00:00+03', 18.95);
INSERT INTO public.hourly_price VALUES ('2023-09-01 12:00:00+03', 24.79);
INSERT INTO public.hourly_price VALUES ('2023-09-01 13:00:00+03', 19.94);
INSERT INTO public.hourly_price VALUES ('2023-09-01 14:00:00+03', 21.19);
INSERT INTO public.hourly_price VALUES ('2023-09-01 15:00:00+03', 14.88);
INSERT INTO public.hourly_price VALUES ('2023-09-01 16:00:00+03', 11.41);
INSERT INTO public.hourly_price VALUES ('2023-09-01 17:00:00+03', 11.02);
INSERT INTO public.hourly_price VALUES ('2023-09-01 18:00:00+03', 11.01);
INSERT INTO public.hourly_price VALUES ('2023-09-01 19:00:00+03', 11.36);
INSERT INTO public.hourly_price VALUES ('2023-09-01 20:00:00+03', 11.7);
INSERT INTO public.hourly_price VALUES ('2023-09-01 21:00:00+03', 18);
INSERT INTO public.hourly_price VALUES ('2023-09-01 22:00:00+03', 18.45);
INSERT INTO public.hourly_price VALUES ('2023-09-01 23:00:00+03', 24.69);
INSERT INTO public.hourly_price VALUES ('2023-09-02 00:00:00+03', 22.37);
INSERT INTO public.hourly_price VALUES ('2023-09-02 01:00:00+03', 16.36);
INSERT INTO public.hourly_price VALUES ('2023-09-02 02:00:00+03', 14.7);
INSERT INTO public.hourly_price VALUES ('2023-09-02 03:00:00+03', 11.06);
INSERT INTO public.hourly_price VALUES ('2023-09-02 04:00:00+03', 4.9);
INSERT INTO public.hourly_price VALUES ('2023-09-02 05:00:00+03', 4.79);
INSERT INTO public.hourly_price VALUES ('2023-09-02 06:00:00+03', 4.34);
INSERT INTO public.hourly_price VALUES ('2023-09-02 07:00:00+03', 4.01);
INSERT INTO public.hourly_price VALUES ('2023-09-02 08:00:00+03', 4.37);
INSERT INTO public.hourly_price VALUES ('2023-09-02 09:00:00+03', 5.75);
INSERT INTO public.hourly_price VALUES ('2023-09-02 10:00:00+03', 9);
INSERT INTO public.hourly_price VALUES ('2023-09-02 11:00:00+03', 12.54);
INSERT INTO public.hourly_price VALUES ('2023-09-02 12:00:00+03', 12.91);
INSERT INTO public.hourly_price VALUES ('2023-09-02 13:00:00+03', 14.02);
INSERT INTO public.hourly_price VALUES ('2023-09-02 14:00:00+03', 11.13);
INSERT INTO public.hourly_price VALUES ('2023-09-02 15:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-09-02 16:00:00+03', 14.71);
INSERT INTO public.hourly_price VALUES ('2023-09-02 17:00:00+03', 11.73);
INSERT INTO public.hourly_price VALUES ('2023-09-02 18:00:00+03', 16.32);
INSERT INTO public.hourly_price VALUES ('2023-09-02 19:00:00+03', 8.61);
INSERT INTO public.hourly_price VALUES ('2023-09-02 20:00:00+03', 9.92);
INSERT INTO public.hourly_price VALUES ('2023-09-02 21:00:00+03', 14.26);
INSERT INTO public.hourly_price VALUES ('2023-09-02 22:00:00+03', 13.64);
INSERT INTO public.hourly_price VALUES ('2023-09-02 23:00:00+03', 15.81);
INSERT INTO public.hourly_price VALUES ('2023-09-03 00:00:00+03', 16.5);
INSERT INTO public.hourly_price VALUES ('2023-09-03 01:00:00+03', 14.3);
INSERT INTO public.hourly_price VALUES ('2023-09-03 02:00:00+03', 13.1);
INSERT INTO public.hourly_price VALUES ('2023-09-03 03:00:00+03', 6.41);
INSERT INTO public.hourly_price VALUES ('2023-09-03 04:00:00+03', 2.83);
INSERT INTO public.hourly_price VALUES ('2023-09-03 05:00:00+03', 2.4);
INSERT INTO public.hourly_price VALUES ('2023-09-03 06:00:00+03', 2.38);
INSERT INTO public.hourly_price VALUES ('2023-09-03 07:00:00+03', 2.39);
INSERT INTO public.hourly_price VALUES ('2023-09-03 08:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-09-03 09:00:00+03', 2.65);
INSERT INTO public.hourly_price VALUES ('2023-09-03 10:00:00+03', 3.6);
INSERT INTO public.hourly_price VALUES ('2023-09-03 11:00:00+03', 3.42);
INSERT INTO public.hourly_price VALUES ('2023-09-03 12:00:00+03', 5.53);
INSERT INTO public.hourly_price VALUES ('2023-09-03 13:00:00+03', 5.39);
INSERT INTO public.hourly_price VALUES ('2023-09-03 14:00:00+03', 5.87);
INSERT INTO public.hourly_price VALUES ('2023-09-03 15:00:00+03', 5.39);
INSERT INTO public.hourly_price VALUES ('2023-09-03 16:00:00+03', 2.65);
INSERT INTO public.hourly_price VALUES ('2023-09-03 17:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-09-03 18:00:00+03', 3.82);
INSERT INTO public.hourly_price VALUES ('2023-09-03 19:00:00+03', 5.02);
INSERT INTO public.hourly_price VALUES ('2023-09-03 20:00:00+03', 6.65);
INSERT INTO public.hourly_price VALUES ('2023-09-03 21:00:00+03', 11.63);
INSERT INTO public.hourly_price VALUES ('2023-09-03 22:00:00+03', 13.55);
INSERT INTO public.hourly_price VALUES ('2023-09-03 23:00:00+03', 5.33);
INSERT INTO public.hourly_price VALUES ('2023-09-04 00:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-09-04 01:00:00+03', 1.98);
INSERT INTO public.hourly_price VALUES ('2023-09-04 02:00:00+03', 1.2);
INSERT INTO public.hourly_price VALUES ('2023-09-04 03:00:00+03', 0.17);
INSERT INTO public.hourly_price VALUES ('2023-09-04 04:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-09-04 05:00:00+03', -0.12);
INSERT INTO public.hourly_price VALUES ('2023-09-04 06:00:00+03', -0.17);
INSERT INTO public.hourly_price VALUES ('2023-09-04 07:00:00+03', -0.18);
INSERT INTO public.hourly_price VALUES ('2023-09-04 08:00:00+03', -0.16);
INSERT INTO public.hourly_price VALUES ('2023-09-04 09:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-04 10:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-09-04 11:00:00+03', 1.58);
INSERT INTO public.hourly_price VALUES ('2023-09-04 12:00:00+03', 2.56);
INSERT INTO public.hourly_price VALUES ('2023-09-04 13:00:00+03', 3.31);
INSERT INTO public.hourly_price VALUES ('2023-09-04 14:00:00+03', 11.24);
INSERT INTO public.hourly_price VALUES ('2023-09-04 15:00:00+03', 5.92);
INSERT INTO public.hourly_price VALUES ('2023-09-04 16:00:00+03', 3.2);
INSERT INTO public.hourly_price VALUES ('2023-09-04 17:00:00+03', 3.32);
INSERT INTO public.hourly_price VALUES ('2023-09-04 18:00:00+03', 2.96);
INSERT INTO public.hourly_price VALUES ('2023-09-04 19:00:00+03', 3.4);
INSERT INTO public.hourly_price VALUES ('2023-09-04 20:00:00+03', 1.53);
INSERT INTO public.hourly_price VALUES ('2023-09-04 21:00:00+03', 0.61);
INSERT INTO public.hourly_price VALUES ('2023-09-04 22:00:00+03', 0.28);
INSERT INTO public.hourly_price VALUES ('2023-09-04 23:00:00+03', 0.07);
INSERT INTO public.hourly_price VALUES ('2023-09-05 00:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-05 01:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-05 02:00:00+03', -0.15);
INSERT INTO public.hourly_price VALUES ('2023-09-05 03:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-09-05 04:00:00+03', -0.51);
INSERT INTO public.hourly_price VALUES ('2023-09-05 05:00:00+03', -0.5);
INSERT INTO public.hourly_price VALUES ('2023-09-05 06:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-09-05 07:00:00+03', -0.07);
INSERT INTO public.hourly_price VALUES ('2023-09-05 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-05 09:00:00+03', 0.5);
INSERT INTO public.hourly_price VALUES ('2023-09-05 10:00:00+03', 1.78);
INSERT INTO public.hourly_price VALUES ('2023-09-05 11:00:00+03', 2.56);
INSERT INTO public.hourly_price VALUES ('2023-09-05 12:00:00+03', 13.64);
INSERT INTO public.hourly_price VALUES ('2023-09-05 13:00:00+03', 16.22);
INSERT INTO public.hourly_price VALUES ('2023-09-05 14:00:00+03', 6.86);
INSERT INTO public.hourly_price VALUES ('2023-09-05 15:00:00+03', 5.15);
INSERT INTO public.hourly_price VALUES ('2023-09-05 16:00:00+03', 12.76);
INSERT INTO public.hourly_price VALUES ('2023-09-05 17:00:00+03', 7.81);
INSERT INTO public.hourly_price VALUES ('2023-09-05 18:00:00+03', 2.42);
INSERT INTO public.hourly_price VALUES ('2023-09-05 19:00:00+03', 1.59);
INSERT INTO public.hourly_price VALUES ('2023-09-05 20:00:00+03', 1.61);
INSERT INTO public.hourly_price VALUES ('2023-09-05 21:00:00+03', 2.96);
INSERT INTO public.hourly_price VALUES ('2023-09-05 22:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-09-05 23:00:00+03', 0.78);
INSERT INTO public.hourly_price VALUES ('2023-09-06 00:00:00+03', 0.44);
INSERT INTO public.hourly_price VALUES ('2023-09-06 01:00:00+03', 0.22);
INSERT INTO public.hourly_price VALUES ('2023-09-06 02:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-06 03:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-09-06 04:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-09-06 05:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-09-06 06:00:00+03', -0.23);
INSERT INTO public.hourly_price VALUES ('2023-09-06 07:00:00+03', -0.44);
INSERT INTO public.hourly_price VALUES ('2023-09-06 08:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-09-06 09:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-06 10:00:00+03', 0.47);
INSERT INTO public.hourly_price VALUES ('2023-09-06 11:00:00+03', 1.85);
INSERT INTO public.hourly_price VALUES ('2023-09-06 12:00:00+03', 2.4);
INSERT INTO public.hourly_price VALUES ('2023-09-06 13:00:00+03', 2.46);
INSERT INTO public.hourly_price VALUES ('2023-09-06 14:00:00+03', 2.38);
INSERT INTO public.hourly_price VALUES ('2023-09-06 15:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-09-06 16:00:00+03', 2.26);
INSERT INTO public.hourly_price VALUES ('2023-09-06 17:00:00+03', 2.27);
INSERT INTO public.hourly_price VALUES ('2023-09-06 18:00:00+03', 2.53);
INSERT INTO public.hourly_price VALUES ('2023-09-06 19:00:00+03', 4.31);
INSERT INTO public.hourly_price VALUES ('2023-09-06 20:00:00+03', 11.34);
INSERT INTO public.hourly_price VALUES ('2023-09-06 21:00:00+03', 13.13);
INSERT INTO public.hourly_price VALUES ('2023-09-06 22:00:00+03', 18.08);
INSERT INTO public.hourly_price VALUES ('2023-09-06 23:00:00+03', 23.5);
INSERT INTO public.hourly_price VALUES ('2023-09-07 00:00:00+03', 20.59);
INSERT INTO public.hourly_price VALUES ('2023-09-07 01:00:00+03', 12.09);
INSERT INTO public.hourly_price VALUES ('2023-09-07 02:00:00+03', 2.55);
INSERT INTO public.hourly_price VALUES ('2023-09-07 03:00:00+03', 2.13);
INSERT INTO public.hourly_price VALUES ('2023-09-07 04:00:00+03', 1.76);
INSERT INTO public.hourly_price VALUES ('2023-09-07 05:00:00+03', 1.59);
INSERT INTO public.hourly_price VALUES ('2023-09-07 06:00:00+03', 1.57);
INSERT INTO public.hourly_price VALUES ('2023-09-07 07:00:00+03', 1.56);
INSERT INTO public.hourly_price VALUES ('2023-09-07 08:00:00+03', 1.58);
INSERT INTO public.hourly_price VALUES ('2023-09-07 09:00:00+03', 1.77);
INSERT INTO public.hourly_price VALUES ('2023-09-07 10:00:00+03', 2.84);
INSERT INTO public.hourly_price VALUES ('2023-09-07 11:00:00+03', 16.12);
INSERT INTO public.hourly_price VALUES ('2023-09-07 12:00:00+03', 15.62);
INSERT INTO public.hourly_price VALUES ('2023-09-07 13:00:00+03', 19.29);
INSERT INTO public.hourly_price VALUES ('2023-09-07 14:00:00+03', 12.62);
INSERT INTO public.hourly_price VALUES ('2023-09-07 15:00:00+03', 8.76);
INSERT INTO public.hourly_price VALUES ('2023-09-07 16:00:00+03', 8.6);
INSERT INTO public.hourly_price VALUES ('2023-09-07 17:00:00+03', 5.94);
INSERT INTO public.hourly_price VALUES ('2023-09-07 18:00:00+03', 4.75);
INSERT INTO public.hourly_price VALUES ('2023-09-07 19:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-09-07 20:00:00+03', 5.96);
INSERT INTO public.hourly_price VALUES ('2023-09-07 21:00:00+03', 6.78);
INSERT INTO public.hourly_price VALUES ('2023-09-07 22:00:00+03', 10.57);
INSERT INTO public.hourly_price VALUES ('2023-09-07 23:00:00+03', 5.95);
INSERT INTO public.hourly_price VALUES ('2023-09-08 00:00:00+03', 3.51);
INSERT INTO public.hourly_price VALUES ('2023-09-08 01:00:00+03', 2.55);
INSERT INTO public.hourly_price VALUES ('2023-09-08 02:00:00+03', 1.94);
INSERT INTO public.hourly_price VALUES ('2023-09-08 03:00:00+03', 1.6);
INSERT INTO public.hourly_price VALUES ('2023-09-08 04:00:00+03', 2.74);
INSERT INTO public.hourly_price VALUES ('2023-09-08 05:00:00+03', 2.35);
INSERT INTO public.hourly_price VALUES ('2023-09-08 06:00:00+03', 2.22);
INSERT INTO public.hourly_price VALUES ('2023-09-08 07:00:00+03', 2.17);
INSERT INTO public.hourly_price VALUES ('2023-09-08 08:00:00+03', 2.82);
INSERT INTO public.hourly_price VALUES ('2023-09-08 09:00:00+03', 11.56);
INSERT INTO public.hourly_price VALUES ('2023-09-08 10:00:00+03', 15);
INSERT INTO public.hourly_price VALUES ('2023-09-08 11:00:00+03', 26.35);
INSERT INTO public.hourly_price VALUES ('2023-09-08 12:00:00+03', 27.29);
INSERT INTO public.hourly_price VALUES ('2023-09-08 13:00:00+03', 15.3);
INSERT INTO public.hourly_price VALUES ('2023-09-08 14:00:00+03', 12.61);
INSERT INTO public.hourly_price VALUES ('2023-09-08 15:00:00+03', 18.01);
INSERT INTO public.hourly_price VALUES ('2023-09-08 16:00:00+03', 14.18);
INSERT INTO public.hourly_price VALUES ('2023-09-08 17:00:00+03', 8.8);
INSERT INTO public.hourly_price VALUES ('2023-09-08 18:00:00+03', 9);
INSERT INTO public.hourly_price VALUES ('2023-09-08 19:00:00+03', 9.95);
INSERT INTO public.hourly_price VALUES ('2023-09-08 20:00:00+03', 10.96);
INSERT INTO public.hourly_price VALUES ('2023-09-08 21:00:00+03', 13.38);
INSERT INTO public.hourly_price VALUES ('2023-09-08 22:00:00+03', 21.06);
INSERT INTO public.hourly_price VALUES ('2023-09-08 23:00:00+03', 27.73);
INSERT INTO public.hourly_price VALUES ('2023-09-09 00:00:00+03', 24.02);
INSERT INTO public.hourly_price VALUES ('2023-09-09 01:00:00+03', 3.17);
INSERT INTO public.hourly_price VALUES ('2023-09-09 02:00:00+03', 1.46);
INSERT INTO public.hourly_price VALUES ('2023-09-09 03:00:00+03', 1.21);
INSERT INTO public.hourly_price VALUES ('2023-09-09 04:00:00+03', 1.43);
INSERT INTO public.hourly_price VALUES ('2023-09-09 05:00:00+03', 0.15);
INSERT INTO public.hourly_price VALUES ('2023-09-09 06:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-09 07:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-09 08:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-09 09:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-09 10:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-09 11:00:00+03', 0.33);
INSERT INTO public.hourly_price VALUES ('2023-09-09 12:00:00+03', 1.55);
INSERT INTO public.hourly_price VALUES ('2023-09-09 13:00:00+03', 1.89);
INSERT INTO public.hourly_price VALUES ('2023-09-09 14:00:00+03', 2.06);
INSERT INTO public.hourly_price VALUES ('2023-09-09 15:00:00+03', 2.02);
INSERT INTO public.hourly_price VALUES ('2023-09-09 16:00:00+03', 1.87);
INSERT INTO public.hourly_price VALUES ('2023-09-09 17:00:00+03', 1.32);
INSERT INTO public.hourly_price VALUES ('2023-09-09 18:00:00+03', 1.45);
INSERT INTO public.hourly_price VALUES ('2023-09-09 19:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-09-09 20:00:00+03', 1.68);
INSERT INTO public.hourly_price VALUES ('2023-09-09 21:00:00+03', 1.66);
INSERT INTO public.hourly_price VALUES ('2023-09-09 22:00:00+03', 1.53);
INSERT INTO public.hourly_price VALUES ('2023-09-09 23:00:00+03', 1.25);
INSERT INTO public.hourly_price VALUES ('2023-09-10 00:00:00+03', 0.14);
INSERT INTO public.hourly_price VALUES ('2023-09-10 01:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-10 02:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-10 03:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-09-10 04:00:00+03', -0.2);
INSERT INTO public.hourly_price VALUES ('2023-09-10 05:00:00+03', -0.18);
INSERT INTO public.hourly_price VALUES ('2023-09-10 06:00:00+03', -0.12);
INSERT INTO public.hourly_price VALUES ('2023-09-10 07:00:00+03', -0.04);
INSERT INTO public.hourly_price VALUES ('2023-09-10 08:00:00+03', -0.06);
INSERT INTO public.hourly_price VALUES ('2023-09-10 09:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-09-10 10:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-10 11:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-10 12:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-10 13:00:00+03', 0.21);
INSERT INTO public.hourly_price VALUES ('2023-09-10 14:00:00+03', 0.58);
INSERT INTO public.hourly_price VALUES ('2023-09-10 15:00:00+03', 1.42);
INSERT INTO public.hourly_price VALUES ('2023-09-10 16:00:00+03', 1.03);
INSERT INTO public.hourly_price VALUES ('2023-09-10 17:00:00+03', 0.24);
INSERT INTO public.hourly_price VALUES ('2023-09-10 18:00:00+03', 0.68);
INSERT INTO public.hourly_price VALUES ('2023-09-10 19:00:00+03', 1.75);
INSERT INTO public.hourly_price VALUES ('2023-09-10 20:00:00+03', 2.12);
INSERT INTO public.hourly_price VALUES ('2023-09-10 21:00:00+03', 2.98);
INSERT INTO public.hourly_price VALUES ('2023-09-10 22:00:00+03', 3.22);
INSERT INTO public.hourly_price VALUES ('2023-09-10 23:00:00+03', 4.98);
INSERT INTO public.hourly_price VALUES ('2023-09-11 00:00:00+03', 3.42);
INSERT INTO public.hourly_price VALUES ('2023-09-11 01:00:00+03', 2.6);
INSERT INTO public.hourly_price VALUES ('2023-09-11 02:00:00+03', 2.48);
INSERT INTO public.hourly_price VALUES ('2023-09-11 03:00:00+03', 1.88);
INSERT INTO public.hourly_price VALUES ('2023-09-11 04:00:00+03', 2.37);
INSERT INTO public.hourly_price VALUES ('2023-09-11 05:00:00+03', 2.16);
INSERT INTO public.hourly_price VALUES ('2023-09-11 06:00:00+03', 2);
INSERT INTO public.hourly_price VALUES ('2023-09-11 07:00:00+03', 2);
INSERT INTO public.hourly_price VALUES ('2023-09-11 08:00:00+03', 3.16);
INSERT INTO public.hourly_price VALUES ('2023-09-11 09:00:00+03', 22.32);
INSERT INTO public.hourly_price VALUES ('2023-09-11 10:00:00+03', 24.8);
INSERT INTO public.hourly_price VALUES ('2023-09-11 11:00:00+03', 34.71);
INSERT INTO public.hourly_price VALUES ('2023-09-11 12:00:00+03', 34.71);
INSERT INTO public.hourly_price VALUES ('2023-09-11 13:00:00+03', 37.21);
INSERT INTO public.hourly_price VALUES ('2023-09-11 14:00:00+03', 30.98);
INSERT INTO public.hourly_price VALUES ('2023-09-11 15:00:00+03', 24.81);
INSERT INTO public.hourly_price VALUES ('2023-09-11 16:00:00+03', 24.8);
INSERT INTO public.hourly_price VALUES ('2023-09-11 17:00:00+03', 18.66);
INSERT INTO public.hourly_price VALUES ('2023-09-11 18:00:00+03', 12.68);
INSERT INTO public.hourly_price VALUES ('2023-09-11 19:00:00+03', 11.47);
INSERT INTO public.hourly_price VALUES ('2023-09-11 20:00:00+03', 12.24);
INSERT INTO public.hourly_price VALUES ('2023-09-11 21:00:00+03', 16.48);
INSERT INTO public.hourly_price VALUES ('2023-09-11 22:00:00+03', 3.08);
INSERT INTO public.hourly_price VALUES ('2023-09-11 23:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-09-12 00:00:00+03', 0.27);
INSERT INTO public.hourly_price VALUES ('2023-09-12 01:00:00+03', 0.08);
INSERT INTO public.hourly_price VALUES ('2023-09-12 02:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-12 03:00:00+03', -0.12);
INSERT INTO public.hourly_price VALUES ('2023-09-12 04:00:00+03', -0.23);
INSERT INTO public.hourly_price VALUES ('2023-09-12 05:00:00+03', -0.21);
INSERT INTO public.hourly_price VALUES ('2023-09-12 06:00:00+03', -0.19);
INSERT INTO public.hourly_price VALUES ('2023-09-12 07:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-09-12 08:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-12 09:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-12 10:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-09-12 11:00:00+03', 1.49);
INSERT INTO public.hourly_price VALUES ('2023-09-12 12:00:00+03', 1.79);
INSERT INTO public.hourly_price VALUES ('2023-09-12 13:00:00+03', 1.79);
INSERT INTO public.hourly_price VALUES ('2023-09-12 14:00:00+03', 1.72);
INSERT INTO public.hourly_price VALUES ('2023-09-12 15:00:00+03', 1.63);
INSERT INTO public.hourly_price VALUES ('2023-09-12 16:00:00+03', 1.56);
INSERT INTO public.hourly_price VALUES ('2023-09-12 17:00:00+03', 1.52);
INSERT INTO public.hourly_price VALUES ('2023-09-12 18:00:00+03', 1.53);
INSERT INTO public.hourly_price VALUES ('2023-09-12 19:00:00+03', 1.58);
INSERT INTO public.hourly_price VALUES ('2023-09-12 20:00:00+03', 1.79);
INSERT INTO public.hourly_price VALUES ('2023-09-12 21:00:00+03', 2.43);
INSERT INTO public.hourly_price VALUES ('2023-09-12 22:00:00+03', 2.36);
INSERT INTO public.hourly_price VALUES ('2023-09-12 23:00:00+03', 2.39);
INSERT INTO public.hourly_price VALUES ('2023-09-13 00:00:00+03', 1.91);
INSERT INTO public.hourly_price VALUES ('2023-09-13 01:00:00+03', 1.83);
INSERT INTO public.hourly_price VALUES ('2023-09-13 02:00:00+03', 1.56);
INSERT INTO public.hourly_price VALUES ('2023-09-13 03:00:00+03', 1.45);
INSERT INTO public.hourly_price VALUES ('2023-09-13 04:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-09-13 05:00:00+03', 1.18);
INSERT INTO public.hourly_price VALUES ('2023-09-13 06:00:00+03', 1.11);
INSERT INTO public.hourly_price VALUES ('2023-09-13 07:00:00+03', 1.1);
INSERT INTO public.hourly_price VALUES ('2023-09-13 08:00:00+03', 1.21);
INSERT INTO public.hourly_price VALUES ('2023-09-13 09:00:00+03', 1.27);
INSERT INTO public.hourly_price VALUES ('2023-09-13 10:00:00+03', 5.98);
INSERT INTO public.hourly_price VALUES ('2023-09-13 11:00:00+03', 18.6);
INSERT INTO public.hourly_price VALUES ('2023-09-13 12:00:00+03', 24.8);
INSERT INTO public.hourly_price VALUES ('2023-09-13 13:00:00+03', 21.1);
INSERT INTO public.hourly_price VALUES ('2023-09-13 14:00:00+03', 24.81);
INSERT INTO public.hourly_price VALUES ('2023-09-13 15:00:00+03', 24.8);
INSERT INTO public.hourly_price VALUES ('2023-09-13 16:00:00+03', 18.6);
INSERT INTO public.hourly_price VALUES ('2023-09-13 17:00:00+03', 14.88);
INSERT INTO public.hourly_price VALUES ('2023-09-13 18:00:00+03', 11.44);
INSERT INTO public.hourly_price VALUES ('2023-09-13 19:00:00+03', 12.5);
INSERT INTO public.hourly_price VALUES ('2023-09-13 20:00:00+03', 22.32);
INSERT INTO public.hourly_price VALUES ('2023-09-13 21:00:00+03', 17.48);
INSERT INTO public.hourly_price VALUES ('2023-09-13 22:00:00+03', 18.9);
INSERT INTO public.hourly_price VALUES ('2023-09-13 23:00:00+03', 19.9);
INSERT INTO public.hourly_price VALUES ('2023-09-14 00:00:00+03', 6.14);
INSERT INTO public.hourly_price VALUES ('2023-09-14 01:00:00+03', 2.95);
INSERT INTO public.hourly_price VALUES ('2023-09-14 02:00:00+03', 1.81);
INSERT INTO public.hourly_price VALUES ('2023-09-14 03:00:00+03', 1.26);
INSERT INTO public.hourly_price VALUES ('2023-09-14 04:00:00+03', 1.37);
INSERT INTO public.hourly_price VALUES ('2023-09-14 05:00:00+03', 1.36);
INSERT INTO public.hourly_price VALUES ('2023-09-14 06:00:00+03', 1.33);
INSERT INTO public.hourly_price VALUES ('2023-09-14 07:00:00+03', 1.35);
INSERT INTO public.hourly_price VALUES ('2023-09-14 08:00:00+03', 1.39);
INSERT INTO public.hourly_price VALUES ('2023-09-14 09:00:00+03', 1.57);
INSERT INTO public.hourly_price VALUES ('2023-09-14 10:00:00+03', 1.89);
INSERT INTO public.hourly_price VALUES ('2023-09-14 11:00:00+03', 11.13);
INSERT INTO public.hourly_price VALUES ('2023-09-14 12:00:00+03', 19.23);
INSERT INTO public.hourly_price VALUES ('2023-09-14 13:00:00+03', 14.63);
INSERT INTO public.hourly_price VALUES ('2023-09-14 14:00:00+03', 12.01);
INSERT INTO public.hourly_price VALUES ('2023-09-14 15:00:00+03', 11.36);
INSERT INTO public.hourly_price VALUES ('2023-09-14 16:00:00+03', 11.32);
INSERT INTO public.hourly_price VALUES ('2023-09-14 17:00:00+03', 11.12);
INSERT INTO public.hourly_price VALUES ('2023-09-14 18:00:00+03', 10.93);
INSERT INTO public.hourly_price VALUES ('2023-09-14 19:00:00+03', 11.12);
INSERT INTO public.hourly_price VALUES ('2023-09-14 20:00:00+03', 11.68);
INSERT INTO public.hourly_price VALUES ('2023-09-14 21:00:00+03', 14.49);
INSERT INTO public.hourly_price VALUES ('2023-09-14 22:00:00+03', 21.45);
INSERT INTO public.hourly_price VALUES ('2023-09-14 23:00:00+03', 28.55);
INSERT INTO public.hourly_price VALUES ('2023-09-15 00:00:00+03', 23.04);
INSERT INTO public.hourly_price VALUES ('2023-09-15 01:00:00+03', 16.53);
INSERT INTO public.hourly_price VALUES ('2023-09-15 02:00:00+03', 14.15);
INSERT INTO public.hourly_price VALUES ('2023-09-15 03:00:00+03', 4.29);
INSERT INTO public.hourly_price VALUES ('2023-09-15 04:00:00+03', 15.5);
INSERT INTO public.hourly_price VALUES ('2023-09-15 05:00:00+03', 15.5);
INSERT INTO public.hourly_price VALUES ('2023-09-15 06:00:00+03', 15.5);
INSERT INTO public.hourly_price VALUES ('2023-09-15 07:00:00+03', 15.5);
INSERT INTO public.hourly_price VALUES ('2023-09-15 08:00:00+03', 15.5);
INSERT INTO public.hourly_price VALUES ('2023-09-15 09:00:00+03', 24.81);
INSERT INTO public.hourly_price VALUES ('2023-09-15 10:00:00+03', 30.98);
INSERT INTO public.hourly_price VALUES ('2023-09-15 11:00:00+03', 31.01);
INSERT INTO public.hourly_price VALUES ('2023-09-15 12:00:00+03', 26.72);
INSERT INTO public.hourly_price VALUES ('2023-09-15 13:00:00+03', 30.97);
INSERT INTO public.hourly_price VALUES ('2023-09-15 14:00:00+03', 31);
INSERT INTO public.hourly_price VALUES ('2023-09-15 15:00:00+03', 17.83);
INSERT INTO public.hourly_price VALUES ('2023-09-15 16:00:00+03', 9.85);
INSERT INTO public.hourly_price VALUES ('2023-09-15 17:00:00+03', 8.1);
INSERT INTO public.hourly_price VALUES ('2023-09-15 18:00:00+03', 8.85);
INSERT INTO public.hourly_price VALUES ('2023-09-15 19:00:00+03', 10.62);
INSERT INTO public.hourly_price VALUES ('2023-09-15 20:00:00+03', 3.93);
INSERT INTO public.hourly_price VALUES ('2023-09-15 21:00:00+03', 2.08);
INSERT INTO public.hourly_price VALUES ('2023-09-15 22:00:00+03', 1.93);
INSERT INTO public.hourly_price VALUES ('2023-09-15 23:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-09-16 00:00:00+03', 1.51);
INSERT INTO public.hourly_price VALUES ('2023-09-16 01:00:00+03', 1.38);
INSERT INTO public.hourly_price VALUES ('2023-09-16 02:00:00+03', 1.11);
INSERT INTO public.hourly_price VALUES ('2023-09-16 03:00:00+03', 0.75);
INSERT INTO public.hourly_price VALUES ('2023-09-16 04:00:00+03', 1.13);
INSERT INTO public.hourly_price VALUES ('2023-09-16 05:00:00+03', 1.09);
INSERT INTO public.hourly_price VALUES ('2023-09-16 06:00:00+03', 1.06);
INSERT INTO public.hourly_price VALUES ('2023-09-16 07:00:00+03', 0.99);
INSERT INTO public.hourly_price VALUES ('2023-09-16 08:00:00+03', 0.99);
INSERT INTO public.hourly_price VALUES ('2023-09-16 09:00:00+03', 0.95);
INSERT INTO public.hourly_price VALUES ('2023-09-16 10:00:00+03', 1.13);
INSERT INTO public.hourly_price VALUES ('2023-09-16 11:00:00+03', 1.26);
INSERT INTO public.hourly_price VALUES ('2023-09-16 12:00:00+03', 1.38);
INSERT INTO public.hourly_price VALUES ('2023-09-16 13:00:00+03', 1.56);
INSERT INTO public.hourly_price VALUES ('2023-09-16 14:00:00+03', 1.62);
INSERT INTO public.hourly_price VALUES ('2023-09-16 15:00:00+03', 1.56);
INSERT INTO public.hourly_price VALUES ('2023-09-16 16:00:00+03', 1.5);
INSERT INTO public.hourly_price VALUES ('2023-09-16 17:00:00+03', 1.44);
INSERT INTO public.hourly_price VALUES ('2023-09-16 18:00:00+03', 1.46);
INSERT INTO public.hourly_price VALUES ('2023-09-16 19:00:00+03', 1.51);
INSERT INTO public.hourly_price VALUES ('2023-09-16 20:00:00+03', 1.57);
INSERT INTO public.hourly_price VALUES ('2023-09-16 21:00:00+03', 1.69);
INSERT INTO public.hourly_price VALUES ('2023-09-16 22:00:00+03', 1.77);
INSERT INTO public.hourly_price VALUES ('2023-09-16 23:00:00+03', 1.68);
INSERT INTO public.hourly_price VALUES ('2023-09-17 00:00:00+03', 1.62);
INSERT INTO public.hourly_price VALUES ('2023-09-17 01:00:00+03', 1.47);
INSERT INTO public.hourly_price VALUES ('2023-09-17 02:00:00+03', 1.28);
INSERT INTO public.hourly_price VALUES ('2023-09-17 03:00:00+03', 1.14);
INSERT INTO public.hourly_price VALUES ('2023-09-17 04:00:00+03', 1.4);
INSERT INTO public.hourly_price VALUES ('2023-09-17 05:00:00+03', 1.3);
INSERT INTO public.hourly_price VALUES ('2023-09-17 06:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-09-17 07:00:00+03', 1.12);
INSERT INTO public.hourly_price VALUES ('2023-09-17 08:00:00+03', 0.76);
INSERT INTO public.hourly_price VALUES ('2023-09-17 09:00:00+03', 0.6);
INSERT INTO public.hourly_price VALUES ('2023-09-17 10:00:00+03', 0.31);
INSERT INTO public.hourly_price VALUES ('2023-09-17 11:00:00+03', 0.56);
INSERT INTO public.hourly_price VALUES ('2023-09-17 12:00:00+03', 1.11);
INSERT INTO public.hourly_price VALUES ('2023-09-17 13:00:00+03', 1.17);
INSERT INTO public.hourly_price VALUES ('2023-09-17 14:00:00+03', 1.16);
INSERT INTO public.hourly_price VALUES ('2023-09-17 15:00:00+03', 1.22);
INSERT INTO public.hourly_price VALUES ('2023-09-17 16:00:00+03', 1.24);
INSERT INTO public.hourly_price VALUES ('2023-09-17 17:00:00+03', 0.51);
INSERT INTO public.hourly_price VALUES ('2023-09-17 18:00:00+03', 0.53);
INSERT INTO public.hourly_price VALUES ('2023-09-17 19:00:00+03', 1.38);
INSERT INTO public.hourly_price VALUES ('2023-09-17 20:00:00+03', 1.55);
INSERT INTO public.hourly_price VALUES ('2023-09-17 21:00:00+03', 1.7);
INSERT INTO public.hourly_price VALUES ('2023-09-17 22:00:00+03', 1.84);
INSERT INTO public.hourly_price VALUES ('2023-09-17 23:00:00+03', 1.98);
INSERT INTO public.hourly_price VALUES ('2023-09-18 00:00:00+03', 1.87);
INSERT INTO public.hourly_price VALUES ('2023-09-18 01:00:00+03', 1.64);
INSERT INTO public.hourly_price VALUES ('2023-09-18 02:00:00+03', 1.52);
INSERT INTO public.hourly_price VALUES ('2023-09-18 03:00:00+03', 1.47);
INSERT INTO public.hourly_price VALUES ('2023-09-18 04:00:00+03', 1.18);
INSERT INTO public.hourly_price VALUES ('2023-09-18 05:00:00+03', 1.1);
INSERT INTO public.hourly_price VALUES ('2023-09-18 06:00:00+03', 1.07);
INSERT INTO public.hourly_price VALUES ('2023-09-18 07:00:00+03', 1.04);
INSERT INTO public.hourly_price VALUES ('2023-09-18 08:00:00+03', 1.07);
INSERT INTO public.hourly_price VALUES ('2023-09-18 09:00:00+03', 1.16);
INSERT INTO public.hourly_price VALUES ('2023-09-18 10:00:00+03', 18);
INSERT INTO public.hourly_price VALUES ('2023-09-18 11:00:00+03', 37.21);
INSERT INTO public.hourly_price VALUES ('2023-09-18 12:00:00+03', 22.32);
INSERT INTO public.hourly_price VALUES ('2023-09-18 13:00:00+03', 4.09);
INSERT INTO public.hourly_price VALUES ('2023-09-18 14:00:00+03', 3.61);
INSERT INTO public.hourly_price VALUES ('2023-09-18 15:00:00+03', 1.65);
INSERT INTO public.hourly_price VALUES ('2023-09-18 16:00:00+03', 1.23);
INSERT INTO public.hourly_price VALUES ('2023-09-18 17:00:00+03', 1.18);
INSERT INTO public.hourly_price VALUES ('2023-09-18 18:00:00+03', 1.1);
INSERT INTO public.hourly_price VALUES ('2023-09-18 19:00:00+03', 1.13);
INSERT INTO public.hourly_price VALUES ('2023-09-18 20:00:00+03', 1.2);
INSERT INTO public.hourly_price VALUES ('2023-09-18 21:00:00+03', 1.18);
INSERT INTO public.hourly_price VALUES ('2023-09-18 22:00:00+03', 1.07);
INSERT INTO public.hourly_price VALUES ('2023-09-18 23:00:00+03', 0.96);
INSERT INTO public.hourly_price VALUES ('2023-09-19 00:00:00+03', 0.62);
INSERT INTO public.hourly_price VALUES ('2023-09-19 01:00:00+03', 0.36);
INSERT INTO public.hourly_price VALUES ('2023-09-19 02:00:00+03', 0.05);
INSERT INTO public.hourly_price VALUES ('2023-09-19 03:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-19 04:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-19 05:00:00+03', -0.02);
INSERT INTO public.hourly_price VALUES ('2023-09-19 06:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-09-19 07:00:00+03', -0.12);
INSERT INTO public.hourly_price VALUES ('2023-09-19 08:00:00+03', -0.11);
INSERT INTO public.hourly_price VALUES ('2023-09-19 09:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-19 10:00:00+03', 0.22);
INSERT INTO public.hourly_price VALUES ('2023-09-19 11:00:00+03', 0.32);
INSERT INTO public.hourly_price VALUES ('2023-09-19 12:00:00+03', 0.37);
INSERT INTO public.hourly_price VALUES ('2023-09-19 13:00:00+03', 0.36);
INSERT INTO public.hourly_price VALUES ('2023-09-19 14:00:00+03', 0.33);
INSERT INTO public.hourly_price VALUES ('2023-09-19 15:00:00+03', 0.19);
INSERT INTO public.hourly_price VALUES ('2023-09-19 16:00:00+03', -0.09);
INSERT INTO public.hourly_price VALUES ('2023-09-19 17:00:00+03', -0.14);
INSERT INTO public.hourly_price VALUES ('2023-09-19 18:00:00+03', -0.19);
INSERT INTO public.hourly_price VALUES ('2023-09-19 19:00:00+03', -0.19);
INSERT INTO public.hourly_price VALUES ('2023-09-19 20:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-19 21:00:00+03', 0.03);
INSERT INTO public.hourly_price VALUES ('2023-09-19 22:00:00+03', 0.03);
INSERT INTO public.hourly_price VALUES ('2023-09-19 23:00:00+03', 0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-20 00:00:00+03', 0);
INSERT INTO public.hourly_price VALUES ('2023-09-20 01:00:00+03', -0.01);
INSERT INTO public.hourly_price VALUES ('2023-09-20 02:00:00+03', -0.05);


--
-- TOC entry 3432 (class 0 OID 40967)
-- Dependencies: 223
-- Data for Name: month_name_lookup; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.month_name_lookup VALUES (1, 'tammikuu', 'januari', 'January', 'januar', 'ocak');
INSERT INTO public.month_name_lookup VALUES (2, 'helmikuu', 'februari', 'February', 'februar', 'şubat');
INSERT INTO public.month_name_lookup VALUES (3, 'maaliskuu', 'mars', 'March', 'märz', 'mart');
INSERT INTO public.month_name_lookup VALUES (4, 'huhtikuu', 'april', 'April', 'april', 'nisan');
INSERT INTO public.month_name_lookup VALUES (5, 'toukokuu', 'maj', 'May', 'mai', 'mayis');
INSERT INTO public.month_name_lookup VALUES (6, 'kesäkuu', 'juni', 'June', 'juni', 'haziran');
INSERT INTO public.month_name_lookup VALUES (7, 'heinäkuu', 'juli', 'July', 'juli', 'temmuz');
INSERT INTO public.month_name_lookup VALUES (8, 'elokuu', 'augusti', 'August', 'august', 'ağustos');
INSERT INTO public.month_name_lookup VALUES (9, 'syyskuu', 'september', 'September', 'september', 'eylül');
INSERT INTO public.month_name_lookup VALUES (10, 'lokakuu', 'oktober', 'October', 'oktober', 'ekim');
INSERT INTO public.month_name_lookup VALUES (11, 'marraskuu', 'november', 'November', 'november', 'kasım');
INSERT INTO public.month_name_lookup VALUES (12, 'joulukuu', 'december', 'December', 'dezemer', 'aralık');


--
-- TOC entry 3433 (class 0 OID 245871)
-- Dependencies: 228
-- Data for Name: observation; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3435 (class 0 OID 295012)
-- Dependencies: 232
-- Data for Name: temperature_observation; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3438 (class 0 OID 295027)
-- Dependencies: 235
-- Data for Name: weather_station; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3431 (class 0 OID 32791)
-- Dependencies: 219
-- Data for Name: weekday_lookup; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.weekday_lookup VALUES (1, 'maanantai', 'måndag', 'monday', 'montag', 'pazartesi');
INSERT INTO public.weekday_lookup VALUES (2, 'tiistai', 'tistag', 'tuesday', 'dienstag', 'sali');
INSERT INTO public.weekday_lookup VALUES (3, 'keskiviikko', 'onsdag', 'wednesday', 'mittwoch', 'carsamba');
INSERT INTO public.weekday_lookup VALUES (4, 'torstai', 'torsdag', 'thursday', 'donnerstag', 'persembe');
INSERT INTO public.weekday_lookup VALUES (5, 'perjantai', 'fredag', 'friday', 'freitag', 'cuma');
INSERT INTO public.weekday_lookup VALUES (6, 'lauantai', 'lördag', 'saturday', 'samstag', 'cumartesi');
INSERT INTO public.weekday_lookup VALUES (7, 'sunnuntai', 'söndag', 'sunday', 'sonntag', 'pazar');


--
-- TOC entry 3437 (class 0 OID 295022)
-- Dependencies: 234
-- Data for Name: wind_direction_observation; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3436 (class 0 OID 295017)
-- Dependencies: 233
-- Data for Name: wind_speed_observation; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3265 (class 2606 OID 286858)
-- Name: forecast forecast_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forecast
    ADD CONSTRAINT forecast_pk PRIMARY KEY ("timestamp", place);


--
-- TOC entry 3257 (class 2606 OID 19491)
-- Name: hourly_price hourly_price_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hourly_price
    ADD CONSTRAINT hourly_price_pk PRIMARY KEY (timeslot);


--
-- TOC entry 3261 (class 2606 OID 40971)
-- Name: month_name_lookup month_name_lookup_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.month_name_lookup
    ADD CONSTRAINT month_name_lookup_pkey PRIMARY KEY (month_number);


--
-- TOC entry 3263 (class 2606 OID 245875)
-- Name: observation observation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observation
    ADD CONSTRAINT observation_pkey PRIMARY KEY ("timestamp", place);


--
-- TOC entry 3267 (class 2606 OID 295016)
-- Name: temperature_observation temperature_observation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temperature_observation
    ADD CONSTRAINT temperature_observation_pkey PRIMARY KEY ("timestamp");


--
-- TOC entry 3273 (class 2606 OID 295033)
-- Name: weather_station weather_station_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_station
    ADD CONSTRAINT weather_station_pkey PRIMARY KEY (place);


--
-- TOC entry 3259 (class 2606 OID 32795)
-- Name: weekday_lookup weekday_lookup_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekday_lookup
    ADD CONSTRAINT weekday_lookup_pk PRIMARY KEY (weekday_number);


--
-- TOC entry 3271 (class 2606 OID 295026)
-- Name: wind_direction_observation wind_direction_observation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wind_direction_observation
    ADD CONSTRAINT wind_direction_observation_pkey PRIMARY KEY ("timestamp");


--
-- TOC entry 3269 (class 2606 OID 295021)
-- Name: wind_speed_observation wind_speed_observation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wind_speed_observation
    ADD CONSTRAINT wind_speed_observation_pkey PRIMARY KEY ("timestamp");


--
-- TOC entry 3274 (class 2606 OID 295034)
-- Name: temperature_observation weather_station_temperature_observation_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temperature_observation
    ADD CONSTRAINT weather_station_temperature_observation_fk FOREIGN KEY (place) REFERENCES public.weather_station(place) NOT VALID;


-- Completed on 2023-12-15 13:47:17

--
-- PostgreSQL database dump complete
--

