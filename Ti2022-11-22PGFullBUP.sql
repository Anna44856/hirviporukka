--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

-- Started on 2022-11-22 15:34:04

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'WIN1252';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 242 (class 1255 OID 27618)
-- Name: add_jakoryhma(integer, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.add_jakoryhma(IN seurue integer, IN ryhman_nimi character varying)
    LANGUAGE sql
    AS $$
INSERT INTO public.jakoryhma (seurue_id,ryhman_nimi) VALUES (seurue, ryhman_nimi);
$$;


SET default_table_access_method = heap;

--
-- TOC entry 209 (class 1259 OID 27619)
-- Name: jasen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jasen (
    jasen_id integer NOT NULL,
    etunimi character varying(50) NOT NULL,
    sukunimi character varying(50) NOT NULL,
    jakeluosoite character varying(30) NOT NULL,
    postinumero character varying(10) NOT NULL,
    postitoimipaikka character varying(30) NOT NULL
);


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE jasen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.jasen IS 'Henkil� joka osallistuu mets�stykseen tai lihanjakoon';


--
-- TOC entry 241 (class 1255 OID 27622)
-- Name: get_member(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_member(id integer) RETURNS SETOF public.jasen
    LANGUAGE sql
    AS $$
SELECT * FROM public.jasen WHERE jasen_id = id;
$$;


--
-- TOC entry 210 (class 1259 OID 27623)
-- Name: aikuinenvasa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aikuinenvasa (
    ikaluokka character varying(10) NOT NULL
);


--
-- TOC entry 211 (class 1259 OID 27626)
-- Name: elain; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.elain (
    elaimen_nimi character varying(20) NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 27629)
-- Name: jakoryhma; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jakoryhma (
    ryhma_id integer NOT NULL,
    seurue_id integer NOT NULL,
    ryhman_nimi character varying(50) NOT NULL
);


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE jakoryhma; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.jakoryhma IS 'Ryhm�, jolle lihaa jaetaan';


--
-- TOC entry 213 (class 1259 OID 27632)
-- Name: jakotapahtuma; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jakotapahtuma (
    tapahtuma_id integer NOT NULL,
    paiva date NOT NULL,
    ryhma_id integer NOT NULL,
    osnimitys character varying(20) NOT NULL,
    maara real NOT NULL,
    kaato_id integer
);


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN jakotapahtuma.maara; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.jakotapahtuma.maara IS 'Jaettu liham��r� kiloina';


--
-- TOC entry 214 (class 1259 OID 27635)
-- Name: jaetut_lihat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.jaetut_lihat AS
 SELECT jakoryhma.ryhman_nimi,
    sum(jakotapahtuma.maara) AS kg
   FROM (public.jakoryhma
     LEFT JOIN public.jakotapahtuma ON ((jakotapahtuma.ryhma_id = jakoryhma.ryhma_id)))
  GROUP BY jakoryhma.ryhman_nimi
  ORDER BY jakoryhma.ryhman_nimi;


--
-- TOC entry 215 (class 1259 OID 27639)
-- Name: jako_ka; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.jako_ka AS
 SELECT avg(jaetut_lihat.kg) AS liha_ka
   FROM public.jaetut_lihat;


--
-- TOC entry 216 (class 1259 OID 27643)
-- Name: jakoryhma_ryhma_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jakoryhma_ryhma_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 216
-- Name: jakoryhma_ryhma_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jakoryhma_ryhma_id_seq OWNED BY public.jakoryhma.ryhma_id;


--
-- TOC entry 217 (class 1259 OID 27644)
-- Name: jasenyys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jasenyys (
    jasenyys_id integer NOT NULL,
    ryhma_id integer NOT NULL,
    jasen_id integer NOT NULL,
    liittyi date NOT NULL,
    poistui date,
    osuus integer DEFAULT 100 NOT NULL
);


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN jasenyys.osuus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.jasenyys.osuus IS 'Muuta pakolliseksi (NOT NULL)';


--
-- TOC entry 218 (class 1259 OID 27648)
-- Name: jakoryhma_yhteenveto; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.jakoryhma_yhteenveto AS
 SELECT jakoryhma.ryhman_nimi AS "ryhm�",
    count(jasenyys.jasen_id) AS "j�seni�",
    ((sum(jasenyys.osuus))::double precision / (100)::real) AS osuuksia
   FROM (public.jakoryhma
     JOIN public.jasenyys ON ((jasenyys.ryhma_id = jakoryhma.ryhma_id)))
  GROUP BY jakoryhma.ryhman_nimi
  ORDER BY jakoryhma.ryhman_nimi;


--
-- TOC entry 219 (class 1259 OID 27652)
-- Name: jakotapahtuma_tapahtuma_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jakotapahtuma_tapahtuma_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 219
-- Name: jakotapahtuma_tapahtuma_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jakotapahtuma_tapahtuma_id_seq OWNED BY public.jakotapahtuma.tapahtuma_id;


--
-- TOC entry 220 (class 1259 OID 27653)
-- Name: jasen_jasen_id_seq_1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jasen_jasen_id_seq_1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 220
-- Name: jasen_jasen_id_seq_1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jasen_jasen_id_seq_1 OWNED BY public.jasen.jasen_id;


--
-- TOC entry 221 (class 1259 OID 27654)
-- Name: jasenyys_jasenyys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jasenyys_jasenyys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 221
-- Name: jasenyys_jasenyys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jasenyys_jasenyys_id_seq OWNED BY public.jasenyys.jasenyys_id;


--
-- TOC entry 222 (class 1259 OID 27655)
-- Name: kaato; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kaato (
    kaato_id integer NOT NULL,
    jasen_id integer NOT NULL,
    kaatopaiva date NOT NULL,
    ruhopaino real NOT NULL,
    paikka_teksti character varying(100) NOT NULL,
    paikka_koordinaatti character varying(100),
    kasittelyid integer NOT NULL,
    elaimen_nimi character varying(20) NOT NULL,
    sukupuoli character varying(10) NOT NULL,
    ikaluokka character varying(10) NOT NULL,
    lisatieto character varying(255)
);


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE kaato; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.kaato IS 'Ampumatapahtuman tiedot';


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN kaato.ruhopaino; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.kaato.ruhopaino IS 'paino kiloina';


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 222
-- Name: COLUMN kaato.paikka_koordinaatti; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.kaato.paikka_koordinaatti IS 'T�m�n kent�n tietotyyppi pit�� oikeasti olla geometry (Postgis-tietotyyppi)';


--
-- TOC entry 223 (class 1259 OID 27658)
-- Name: kaadot_ampujittain; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.kaadot_ampujittain AS
 SELECT (((jasen.etunimi)::text || ' '::text) || (jasen.sukunimi)::text) AS ampuja,
    kaato.elaimen_nimi AS "el�in",
    kaato.sukupuoli,
    kaato.ikaluokka,
    count(kaato.elaimen_nimi) AS kpl,
    sum(kaato.ruhopaino) AS kg
   FROM (public.kaato
     JOIN public.jasen ON ((jasen.jasen_id = kaato.jasen_id)))
  GROUP BY (((jasen.etunimi)::text || ' '::text) || (jasen.sukunimi)::text), kaato.elaimen_nimi, kaato.sukupuoli, kaato.ikaluokka
  ORDER BY (((jasen.etunimi)::text || ' '::text) || (jasen.sukunimi)::text);


--
-- TOC entry 224 (class 1259 OID 27663)
-- Name: kaadot_ryhmittain; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.kaadot_ryhmittain AS
 SELECT jakoryhma.ryhman_nimi,
    kaato.elaimen_nimi,
    kaato.sukupuoli,
    kaato.ikaluokka,
    count(kaato.elaimen_nimi) AS kpl,
    sum(kaato.ruhopaino) AS kg
   FROM ((public.jakoryhma
     JOIN public.jasenyys ON ((jakoryhma.ryhma_id = jasenyys.ryhma_id)))
     JOIN public.kaato ON ((jasenyys.jasen_id = kaato.jasen_id)))
  GROUP BY jakoryhma.ryhman_nimi, kaato.elaimen_nimi, kaato.sukupuoli, kaato.ikaluokka;


--
-- TOC entry 225 (class 1259 OID 27668)
-- Name: kaato_kaato_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kaato_kaato_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 225
-- Name: kaato_kaato_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kaato_kaato_id_seq OWNED BY public.kaato.kaato_id;


--
-- TOC entry 227 (class 1259 OID 27673)
-- Name: kasittely; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kasittely (
    kasittelyid integer NOT NULL,
    kasittely_teksti character varying(50) NOT NULL
);


--
-- TOC entry 239 (class 1259 OID 27822)
-- Name: kaatoluettelo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.kaatoluettelo AS
 SELECT (((jasen.sukunimi)::text || ' '::text) || (jasen.etunimi)::text) AS kaataja,
    kaato.kaatopaiva AS "kaatop�iv�",
    kaato.paikka_teksti AS paikka,
    kaato.elaimen_nimi AS "el�in",
    kaato.ikaluokka AS "ik�ryhm�",
    kaato.sukupuoli,
    kaato.ruhopaino AS paino,
    kasittely.kasittely_teksti AS "k�ytt�"
   FROM ((public.jasen
     JOIN public.kaato ON ((jasen.jasen_id = kaato.jasen_id)))
     JOIN public.kasittely ON ((kaato.kasittelyid = kasittely.kasittelyid)))
  ORDER BY kaato.kaato_id DESC;


--
-- TOC entry 226 (class 1259 OID 27669)
-- Name: kaatoyhteenveto; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.kaatoyhteenveto AS
 SELECT kaato.elaimen_nimi,
    kaato.sukupuoli,
    kaato.ikaluokka,
    count(kaato.elaimen_nimi) AS kpl,
    sum(kaato.ruhopaino) AS kg
   FROM public.kaato
  GROUP BY kaato.elaimen_nimi, kaato.sukupuoli, kaato.ikaluokka;


--
-- TOC entry 228 (class 1259 OID 27676)
-- Name: kasittely_kasittelyid_seq_1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kasittely_kasittelyid_seq_1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 228
-- Name: kasittely_kasittelyid_seq_1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kasittely_kasittelyid_seq_1 OWNED BY public.kasittely.kasittelyid;


--
-- TOC entry 229 (class 1259 OID 27677)
-- Name: lupa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lupa (
    luparivi_id integer NOT NULL,
    seura_id integer NOT NULL,
    lupavuosi character varying(4) NOT NULL,
    elaimen_nimi character varying(20) NOT NULL,
    sukupuoli character varying(10) NOT NULL,
    ikaluokka character varying(10) NOT NULL,
    maara integer NOT NULL
);


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE lupa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.lupa IS 'Vuosittaiset kaatoluvat';


--
-- TOC entry 230 (class 1259 OID 27680)
-- Name: lupa_luparivi_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lupa_luparivi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 230
-- Name: lupa_luparivi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lupa_luparivi_id_seq OWNED BY public.lupa.luparivi_id;


--
-- TOC entry 240 (class 1259 OID 27827)
-- Name: nimivalinta; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.nimivalinta AS
 SELECT jasen.jasen_id,
    (((jasen.sukunimi)::text || ' '::text) || (jasen.etunimi)::text) AS kokonimi
   FROM public.jasen
  ORDER BY (((jasen.sukunimi)::text || ' '::text) || (jasen.etunimi)::text);


--
-- TOC entry 231 (class 1259 OID 27681)
-- Name: ruhonosa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ruhonosa (
    osnimitys character varying(20) NOT NULL
);


--
-- TOC entry 232 (class 1259 OID 27684)
-- Name: ryhmien_osuudet; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ryhmien_osuudet AS
 SELECT jasenyys.ryhma_id AS "ryhm�",
    ((sum(jasenyys.osuus))::double precision / (100)::double precision) AS osuuksia
   FROM public.jasenyys
  GROUP BY jasenyys.ryhma_id
  ORDER BY jasenyys.ryhma_id;


--
-- TOC entry 233 (class 1259 OID 27688)
-- Name: seura; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seura (
    seura_id integer NOT NULL,
    seuran_nimi character varying(50) NOT NULL,
    jakeluosoite character varying(30) NOT NULL,
    postinumero character varying(10) NOT NULL,
    postitoimipaikka character varying(30) NOT NULL
);


--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE seura; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.seura IS 'Mets�stysseuran tiedot';


--
-- TOC entry 234 (class 1259 OID 27691)
-- Name: seura_seura_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seura_seura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 234
-- Name: seura_seura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seura_seura_id_seq OWNED BY public.seura.seura_id;


--
-- TOC entry 235 (class 1259 OID 27692)
-- Name: seurue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seurue (
    seurue_id integer NOT NULL,
    seura_id integer NOT NULL,
    seurueen_nimi character varying(50) NOT NULL,
    jasen_id integer NOT NULL
);


--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE seurue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.seurue IS 'Mets�styst� harjoittavan seurueen tiedot
';


--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN seurue.jasen_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.seurue.jasen_id IS 'Seurueen johtajan tunniste';


--
-- TOC entry 236 (class 1259 OID 27695)
-- Name: seurue_seurue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seurue_seurue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 236
-- Name: seurue_seurue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seurue_seurue_id_seq OWNED BY public.seurue.seurue_id;


--
-- TOC entry 237 (class 1259 OID 27696)
-- Name: sukupuoli; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sukupuoli (
    sukupuoli character varying(10) NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 27699)
-- Name: testi_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.testi_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 238
-- Name: testi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.testi_seq OWNED BY public.jakoryhma.ryhma_id;


--
-- TOC entry 3260 (class 2604 OID 27700)
-- Name: jakoryhma ryhma_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jakoryhma ALTER COLUMN ryhma_id SET DEFAULT nextval('public.jakoryhma_ryhma_id_seq'::regclass);


--
-- TOC entry 3261 (class 2604 OID 27701)
-- Name: jakotapahtuma tapahtuma_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jakotapahtuma ALTER COLUMN tapahtuma_id SET DEFAULT nextval('public.jakotapahtuma_tapahtuma_id_seq'::regclass);


--
-- TOC entry 3259 (class 2604 OID 27702)
-- Name: jasen jasen_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jasen ALTER COLUMN jasen_id SET DEFAULT nextval('public.jasen_jasen_id_seq_1'::regclass);


--
-- TOC entry 3263 (class 2604 OID 27703)
-- Name: jasenyys jasenyys_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jasenyys ALTER COLUMN jasenyys_id SET DEFAULT nextval('public.jasenyys_jasenyys_id_seq'::regclass);


--
-- TOC entry 3264 (class 2604 OID 27704)
-- Name: kaato kaato_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kaato ALTER COLUMN kaato_id SET DEFAULT nextval('public.kaato_kaato_id_seq'::regclass);


--
-- TOC entry 3265 (class 2604 OID 27705)
-- Name: kasittely kasittelyid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kasittely ALTER COLUMN kasittelyid SET DEFAULT nextval('public.kasittely_kasittelyid_seq_1'::regclass);


--
-- TOC entry 3266 (class 2604 OID 27706)
-- Name: lupa luparivi_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lupa ALTER COLUMN luparivi_id SET DEFAULT nextval('public.lupa_luparivi_id_seq'::regclass);


--
-- TOC entry 3267 (class 2604 OID 27707)
-- Name: seura seura_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seura ALTER COLUMN seura_id SET DEFAULT nextval('public.seura_seura_id_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 27708)
-- Name: seurue seurue_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seurue ALTER COLUMN seurue_id SET DEFAULT nextval('public.seurue_seurue_id_seq'::regclass);


--
-- TOC entry 3461 (class 0 OID 27623)
-- Dependencies: 210
-- Data for Name: aikuinenvasa; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.aikuinenvasa VALUES ('Aikuinen');
INSERT INTO public.aikuinenvasa VALUES ('Vasa');


--
-- TOC entry 3462 (class 0 OID 27626)
-- Dependencies: 211
-- Data for Name: elain; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.elain VALUES ('Hirvi');
INSERT INTO public.elain VALUES ('Valkoh�nt�peura');


--
-- TOC entry 3463 (class 0 OID 27629)
-- Dependencies: 212
-- Data for Name: jakoryhma; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.jakoryhma VALUES (1, 1, 'Ryhm� 1');
INSERT INTO public.jakoryhma VALUES (2, 1, 'Ryhm� 2');
INSERT INTO public.jakoryhma VALUES (3, 2, 'Ryhm� 3');
INSERT INTO public.jakoryhma VALUES (4, 1, 'Ryhm� 4');
INSERT INTO public.jakoryhma VALUES (6, 1, 'Testiryhm�');


--
-- TOC entry 3464 (class 0 OID 27632)
-- Dependencies: 213
-- Data for Name: jakotapahtuma; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.jakotapahtuma VALUES (1, '2022-10-05', 1, 'Koko', 210, NULL);
INSERT INTO public.jakotapahtuma VALUES (2, '2022-10-02', 1, 'Puolikas', 75, NULL);
INSERT INTO public.jakotapahtuma VALUES (3, '2022-10-02', 2, 'Puolikas', 75, NULL);


--
-- TOC entry 3460 (class 0 OID 27619)
-- Dependencies: 209
-- Data for Name: jasen; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.jasen VALUES (1, 'Janne', 'Jousi', 'Kotikatu 2', '21200', 'Raisio');
INSERT INTO public.jasen VALUES (2, 'Tauno', 'Tappara', 'Viertotie 5', '23100', 'Myn�m�ki');
INSERT INTO public.jasen VALUES (3, 'Kalle', 'Kaaripyssy', 'Isotie 144', '23100', 'Myn�m�ki');
INSERT INTO public.jasen VALUES (4, 'Heikki', 'Haulikko', 'Pikkutie 22', '23100', 'Myn�m�ki');
INSERT INTO public.jasen VALUES (5, 'Tauno', 'Tussari', 'Isotie 210', '23100', 'Myn�m�ki');
INSERT INTO public.jasen VALUES (6, 'Piia', 'Pyssy', 'Jokikatu 2', '23100', 'Myn�m�ki');
INSERT INTO public.jasen VALUES (7, 'Tiina', 'Talikko', 'Kirkkotie 7', '23100', 'Myn�m�ki');
INSERT INTO public.jasen VALUES (8, 'Bertil', 'B�ssa', 'Hemv�g 4', '20100', '�bo');
INSERT INTO public.jasen VALUES (9, 'Ville', 'Vesuri', 'Jokikatu 2', '23100', 'Myn�m�ki');
INSERT INTO public.jasen VALUES (10, 'Kurt', 'Kirves', 'Pohjanperkontie 122', '23100', 'Myn�m�ki');


--
-- TOC entry 3466 (class 0 OID 27644)
-- Dependencies: 217
-- Data for Name: jasenyys; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.jasenyys VALUES (1, 1, 1, '2022-01-01', NULL, 100);
INSERT INTO public.jasenyys VALUES (2, 1, 2, '2022-01-01', NULL, 100);
INSERT INTO public.jasenyys VALUES (3, 1, 3, '2022-01-01', NULL, 100);
INSERT INTO public.jasenyys VALUES (4, 2, 4, '2022-01-01', NULL, 100);
INSERT INTO public.jasenyys VALUES (6, 2, 6, '2022-01-01', NULL, 100);
INSERT INTO public.jasenyys VALUES (7, 3, 7, '2022-01-01', NULL, 100);
INSERT INTO public.jasenyys VALUES (8, 3, 8, '2022-01-01', NULL, 100);
INSERT INTO public.jasenyys VALUES (9, 3, 9, '2022-01-01', NULL, 50);


--
-- TOC entry 3470 (class 0 OID 27655)
-- Dependencies: 222
-- Data for Name: kaato; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.kaato VALUES (1, 5, '2022-09-28', 250, 'Takapellon etel�p��, Jyrkk�l�', '61.58,21.54', 1, 'Hirvi', 'Uros', 'Aikuinen', NULL);
INSERT INTO public.kaato VALUES (2, 6, '2022-09-28', 200, 'Takapellon etel�p��, Jyrkk�l�', '61.58,21.54', 2, 'Hirvi', 'Naaras', 'Aikuinen', NULL);
INSERT INTO public.kaato VALUES (4, 8, '2022-11-15', 100, 'Raimela', NULL, 2, 'Valkoh�nt�peura', 'Naaras', 'Aikuinen', 'Hiihoo');


--
-- TOC entry 3472 (class 0 OID 27673)
-- Dependencies: 227
-- Data for Name: kasittely; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.kasittely VALUES (1, 'Seuralle');
INSERT INTO public.kasittely VALUES (2, 'Seurueelle');
INSERT INTO public.kasittely VALUES (3, 'Myyntiin');
INSERT INTO public.kasittely VALUES (4, 'H�vitet��n');


--
-- TOC entry 3474 (class 0 OID 27677)
-- Dependencies: 229
-- Data for Name: lupa; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.lupa VALUES (1, 1, '2022', 'Hirvi', 'Uros', 'Aikuinen', 10);
INSERT INTO public.lupa VALUES (2, 1, '2022', 'Hirvi', 'Naaras', 'Aikuinen', 15);
INSERT INTO public.lupa VALUES (3, 1, '2022', 'Valkoh�nt�peura', 'Uros', 'Aikuinen', 100);
INSERT INTO public.lupa VALUES (4, 1, '2022', 'Valkoh�nt�peura', 'Naaras', 'Aikuinen', 200);
INSERT INTO public.lupa VALUES (5, 1, '2022', 'Hirvi', 'Uros', 'Vasa', 20);


--
-- TOC entry 3476 (class 0 OID 27681)
-- Dependencies: 231
-- Data for Name: ruhonosa; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ruhonosa VALUES ('Koko');
INSERT INTO public.ruhonosa VALUES ('Puolikas');
INSERT INTO public.ruhonosa VALUES ('Nelj�nnes');


--
-- TOC entry 3477 (class 0 OID 27688)
-- Dependencies: 233
-- Data for Name: seura; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.seura VALUES (1, 'Punaiset hatut ja nen�t', 'Keskuskatu 1', '23100', 'Myn�m�ki');


--
-- TOC entry 3479 (class 0 OID 27692)
-- Dependencies: 235
-- Data for Name: seurue; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.seurue VALUES (1, 1, 'Seurue1', 6);
INSERT INTO public.seurue VALUES (2, 1, 'Seurue2', 1);


--
-- TOC entry 3481 (class 0 OID 27696)
-- Dependencies: 237
-- Data for Name: sukupuoli; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sukupuoli VALUES ('Uros');
INSERT INTO public.sukupuoli VALUES ('Naaras');


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 216
-- Name: jakoryhma_ryhma_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jakoryhma_ryhma_id_seq', 6, true);


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 219
-- Name: jakotapahtuma_tapahtuma_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jakotapahtuma_tapahtuma_id_seq', 3, true);


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 220
-- Name: jasen_jasen_id_seq_1; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jasen_jasen_id_seq_1', 10, true);


--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 221
-- Name: jasenyys_jasenyys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jasenyys_jasenyys_id_seq', 9, true);


--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 225
-- Name: kaato_kaato_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.kaato_kaato_id_seq', 4, true);


--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 228
-- Name: kasittely_kasittelyid_seq_1; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.kasittely_kasittelyid_seq_1', 4, true);


--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 230
-- Name: lupa_luparivi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lupa_luparivi_id_seq', 5, true);


--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 234
-- Name: seura_seura_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seura_seura_id_seq', 1, true);


--
-- TOC entry 3517 (class 0 OID 0)
-- Dependencies: 236
-- Name: seurue_seurue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seurue_seurue_id_seq', 2, true);


--
-- TOC entry 3518 (class 0 OID 0)
-- Dependencies: 238
-- Name: testi_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.testi_seq', 1, false);


--
-- TOC entry 3272 (class 2606 OID 27710)
-- Name: aikuinenvasa aikuinenvasa_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aikuinenvasa
    ADD CONSTRAINT aikuinenvasa_pk PRIMARY KEY (ikaluokka);


--
-- TOC entry 3274 (class 2606 OID 27712)
-- Name: elain elain_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elain
    ADD CONSTRAINT elain_pk PRIMARY KEY (elaimen_nimi);


--
-- TOC entry 3276 (class 2606 OID 27714)
-- Name: jakoryhma jakoryhma_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jakoryhma
    ADD CONSTRAINT jakoryhma_pk PRIMARY KEY (ryhma_id);


--
-- TOC entry 3278 (class 2606 OID 27716)
-- Name: jakotapahtuma jakotapahtuma_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jakotapahtuma
    ADD CONSTRAINT jakotapahtuma_pk PRIMARY KEY (tapahtuma_id);


--
-- TOC entry 3270 (class 2606 OID 27718)
-- Name: jasen jasen_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jasen
    ADD CONSTRAINT jasen_pk PRIMARY KEY (jasen_id);


--
-- TOC entry 3280 (class 2606 OID 27720)
-- Name: jasenyys jasenyys_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jasenyys
    ADD CONSTRAINT jasenyys_pk PRIMARY KEY (jasenyys_id);


--
-- TOC entry 3282 (class 2606 OID 27722)
-- Name: kaato kaato_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kaato
    ADD CONSTRAINT kaato_pk PRIMARY KEY (kaato_id);


--
-- TOC entry 3284 (class 2606 OID 27724)
-- Name: kasittely kasittely_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kasittely
    ADD CONSTRAINT kasittely_pk PRIMARY KEY (kasittelyid);


--
-- TOC entry 3286 (class 2606 OID 27726)
-- Name: lupa lupa_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lupa
    ADD CONSTRAINT lupa_pk PRIMARY KEY (luparivi_id);


--
-- TOC entry 3288 (class 2606 OID 27728)
-- Name: ruhonosa ruhonosa_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruhonosa
    ADD CONSTRAINT ruhonosa_pk PRIMARY KEY (osnimitys);


--
-- TOC entry 3290 (class 2606 OID 27730)
-- Name: seura seura_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seura
    ADD CONSTRAINT seura_pk PRIMARY KEY (seura_id);


--
-- TOC entry 3292 (class 2606 OID 27732)
-- Name: seurue seurue_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seurue
    ADD CONSTRAINT seurue_pk PRIMARY KEY (seurue_id);


--
-- TOC entry 3294 (class 2606 OID 27734)
-- Name: sukupuoli sukupuoli_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sukupuoli
    ADD CONSTRAINT sukupuoli_pk PRIMARY KEY (sukupuoli);


--
-- TOC entry 3301 (class 2606 OID 27735)
-- Name: kaato aikuinen_vasa_kaato_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kaato
    ADD CONSTRAINT aikuinen_vasa_kaato_fk FOREIGN KEY (ikaluokka) REFERENCES public.aikuinenvasa(ikaluokka);


--
-- TOC entry 3306 (class 2606 OID 27740)
-- Name: lupa aikuinen_vasa_lupa_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lupa
    ADD CONSTRAINT aikuinen_vasa_lupa_fk FOREIGN KEY (ikaluokka) REFERENCES public.aikuinenvasa(ikaluokka);


--
-- TOC entry 3302 (class 2606 OID 27745)
-- Name: kaato elain_kaato_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kaato
    ADD CONSTRAINT elain_kaato_fk FOREIGN KEY (elaimen_nimi) REFERENCES public.elain(elaimen_nimi);


--
-- TOC entry 3307 (class 2606 OID 27750)
-- Name: lupa elain_lupa_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lupa
    ADD CONSTRAINT elain_lupa_fk FOREIGN KEY (elaimen_nimi) REFERENCES public.elain(elaimen_nimi);


--
-- TOC entry 3299 (class 2606 OID 27755)
-- Name: jasenyys jasen_jasenyys_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jasenyys
    ADD CONSTRAINT jasen_jasenyys_fk FOREIGN KEY (jasen_id) REFERENCES public.jasen(jasen_id);


--
-- TOC entry 3303 (class 2606 OID 27760)
-- Name: kaato jasen_kaato_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kaato
    ADD CONSTRAINT jasen_kaato_fk FOREIGN KEY (jasen_id) REFERENCES public.jasen(jasen_id);


--
-- TOC entry 3310 (class 2606 OID 27765)
-- Name: seurue jasen_seurue_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seurue
    ADD CONSTRAINT jasen_seurue_fk FOREIGN KEY (jasen_id) REFERENCES public.jasen(jasen_id);


--
-- TOC entry 3296 (class 2606 OID 27770)
-- Name: jakotapahtuma kaato_jakotapahtuma_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jakotapahtuma
    ADD CONSTRAINT kaato_jakotapahtuma_fk FOREIGN KEY (kaato_id) REFERENCES public.kaato(kaato_id) NOT VALID;


--
-- TOC entry 3304 (class 2606 OID 27775)
-- Name: kaato kasittely_kaato_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kaato
    ADD CONSTRAINT kasittely_kaato_fk FOREIGN KEY (kasittelyid) REFERENCES public.kasittely(kasittelyid);


--
-- TOC entry 3297 (class 2606 OID 27780)
-- Name: jakotapahtuma ruhonosa_jakotapahtuma_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jakotapahtuma
    ADD CONSTRAINT ruhonosa_jakotapahtuma_fk FOREIGN KEY (osnimitys) REFERENCES public.ruhonosa(osnimitys);


--
-- TOC entry 3298 (class 2606 OID 27785)
-- Name: jakotapahtuma ryhma_jakotapahtuma_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jakotapahtuma
    ADD CONSTRAINT ryhma_jakotapahtuma_fk FOREIGN KEY (ryhma_id) REFERENCES public.jakoryhma(ryhma_id);


--
-- TOC entry 3300 (class 2606 OID 27790)
-- Name: jasenyys ryhma_jasenyys_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jasenyys
    ADD CONSTRAINT ryhma_jasenyys_fk FOREIGN KEY (ryhma_id) REFERENCES public.jakoryhma(ryhma_id);


--
-- TOC entry 3308 (class 2606 OID 27795)
-- Name: lupa seura_lupa_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lupa
    ADD CONSTRAINT seura_lupa_fk FOREIGN KEY (seura_id) REFERENCES public.seura(seura_id);


--
-- TOC entry 3311 (class 2606 OID 27800)
-- Name: seurue seura_seurue_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seurue
    ADD CONSTRAINT seura_seurue_fk FOREIGN KEY (seura_id) REFERENCES public.seura(seura_id);


--
-- TOC entry 3295 (class 2606 OID 27805)
-- Name: jakoryhma seurue_ryhma_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jakoryhma
    ADD CONSTRAINT seurue_ryhma_fk FOREIGN KEY (seurue_id) REFERENCES public.seurue(seurue_id);


--
-- TOC entry 3305 (class 2606 OID 27810)
-- Name: kaato sukupuoli_kaato_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kaato
    ADD CONSTRAINT sukupuoli_kaato_fk FOREIGN KEY (sukupuoli) REFERENCES public.sukupuoli(sukupuoli);


--
-- TOC entry 3309 (class 2606 OID 27815)
-- Name: lupa sukupuoli_lupa_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lupa
    ADD CONSTRAINT sukupuoli_lupa_fk FOREIGN KEY (sukupuoli) REFERENCES public.sukupuoli(sukupuoli);


-- Completed on 2022-11-22 15:34:05

--
-- PostgreSQL database dump complete
--
