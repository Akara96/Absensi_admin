-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 09, 2026 at 05:52 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_absensi`
--

-- --------------------------------------------------------

--
-- Table structure for table `api_funsonariu`
--

CREATE TABLE `api_funsonariu` (
  `id` bigint(20) NOT NULL,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `nre` varchar(20) NOT NULL,
  `naran` varchar(100) NOT NULL,
  `kargu` varchar(100) NOT NULL,
  `unidade_traballu` varchar(100) NOT NULL,
  `grau` varchar(5) NOT NULL,
  `numeru_telefoni` varchar(20) NOT NULL,
  `foto` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_admin` tinyint(1) NOT NULL,
  `data_tama` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `api_funsonariu`
--

INSERT INTO `api_funsonariu` (`id`, `password`, `last_login`, `nre`, `naran`, `kargu`, `unidade_traballu`, `grau`, `numeru_telefoni`, `foto`, `is_active`, `is_admin`, `data_tama`) VALUES
(1, 'pbkdf2_sha256$600000$jsVjxslnnlT4axeElTq2Er$WpSUPNSxxkYHmsfWWlYydMWZnLfb+9LQF0YL+7gfAKg=', '2026-04-08 17:51:15.363877', 'admin01', 'Administrator', '', '', '', '', '', 1, 1, '2026-04-05'),
(2, 'pbkdf2_sha256$600000$aXw2RiyAnCY7h1cfikhyOW$/LmAuG9Mla3ef3EkNYTYuWRTKxUwZPyOS8KPs5NEGsM=', NULL, 'admin02', 'Vivencio', 'Staff', 'IT', 'I', '76254415', 'foto_pegawai/lead_architect.png', 1, 0, '2026-04-05');

-- --------------------------------------------------------

--
-- Table structure for table `api_konfigurasaun_sistema`
--

CREATE TABLE `api_konfigurasaun_sistema` (
  `id` bigint(20) NOT NULL,
  `jam_masuk_mulai` time(6) NOT NULL,
  `jam_masuk_akhir` time(6) NOT NULL,
  `jam_keluar_istirahat` time(6) NOT NULL,
  `jam_masuk_siang` time(6) NOT NULL,
  `jam_keluar_sore` time(6) NOT NULL,
  `batas_radius_meter` int(11) NOT NULL,
  `last_message` varchar(255) NOT NULL,
  `updated_at` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `api_konfigurasaun_sistema`
--

INSERT INTO `api_konfigurasaun_sistema` (`id`, `jam_masuk_mulai`, `jam_masuk_akhir`, `jam_keluar_istirahat`, `jam_masuk_siang`, `jam_keluar_sore`, `batas_radius_meter`, `last_message`, `updated_at`) VALUES
(1, '06:00:00.000000', '08:00:00.000000', '12:00:00.000000', '13:30:00.000000', '17:30:00.000000', 50, 'Feriadu \'feriadu\' (2026-04-08) hamoos ona.', '2026-04-08 03:43:44.661406');

-- --------------------------------------------------------

--
-- Table structure for table `api_loron_feriadu`
--

CREATE TABLE `api_loron_feriadu` (
  `id` bigint(20) NOT NULL,
  `tanggal` date NOT NULL,
  `keterangan` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `api_pedidu_lisensa`
--

CREATE TABLE `api_pedidu_lisensa` (
  `id` bigint(20) NOT NULL,
  `tipe_izin` varchar(10) NOT NULL,
  `tanggal_mulai` date NOT NULL,
  `tanggal_selesai` date NOT NULL,
  `keterangan` longtext NOT NULL,
  `file_bukti` varchar(100) NOT NULL,
  `status_pengajuan` varchar(20) NOT NULL,
  `waktu_pengajuan` datetime(6) NOT NULL,
  `funsonariu_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `api_pedidu_lisensa`
--

INSERT INTO `api_pedidu_lisensa` (`id`, `tipe_izin`, `tanggal_mulai`, `tanggal_selesai`, `keterangan`, `file_bukti`, `status_pengajuan`, `waktu_pengajuan`, `funsonariu_id`) VALUES
(1, 'izin', '2026-04-08', '2026-04-09', 'moras', 'bukti_izin/scaled_f943afa1-3436-494d-9346-d11c258cdd516032658080545437642.jpg', 'disetujui', '2026-04-07 19:58:09.039497', 2);

-- --------------------------------------------------------

--
-- Table structure for table `api_presensa`
--

CREATE TABLE `api_presensa` (
  `id` bigint(20) NOT NULL,
  `tempu_tama` datetime(6) NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `distansia_metru` double NOT NULL,
  `status` varchar(20) NOT NULL,
  `komentariu` longtext NOT NULL,
  `funsonariu_id` bigint(20) NOT NULL,
  `tempu_sai` datetime(6) DEFAULT NULL,
  `tempu_sai_deskansa` datetime(6) DEFAULT NULL,
  `tempu_tama_lokraik` datetime(6) DEFAULT NULL,
  `durasi_lembur` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `api_presensa`
--

INSERT INTO `api_presensa` (`id`, `tempu_tama`, `latitude`, `longitude`, `distansia_metru`, `status`, `komentariu`, `funsonariu_id`, `tempu_sai`, `tempu_sai_deskansa`, `tempu_tama_lokraik`, `durasi_lembur`) VALUES
(1, '2026-04-04 21:19:14.932304', -8.5535513, 125.5224651, 214.84908409957896, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(2, '2026-04-04 21:30:53.150426', -8.5533836, 125.5231987, 134.57461578785635, 'terlambat', '', 1, NULL, NULL, NULL, 0),
(3, '2026-04-04 21:31:27.960730', -8.5533836, 125.5231987, 134.57461578785635, 'terlambat', '', 1, NULL, NULL, NULL, 0),
(4, '2026-04-04 22:31:32.098481', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(5, '2026-04-04 22:31:55.023897', -8.5535512, 125.522493, 211.77881199935146, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(6, '2026-04-04 22:32:33.705855', -8.5535517, 125.5224917, 211.92350560386953, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(7, '2026-04-04 22:38:09.554499', -8.5534145, 125.5228662, 170.83925417781833, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(8, '2026-04-04 22:39:19.920380', -8.5534345, 125.5224114, 220.77180485139417, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(9, '2026-04-04 22:45:45.388291', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(10, '2026-04-04 22:57:49.317476', -8.5533836, 125.5231987, 134.57461578785635, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(11, '2026-04-04 22:59:21.912998', -8.5533836, 125.5231987, 134.57461578785635, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(12, '2026-04-04 22:59:45.012367', -8.5533836, 125.5231987, 134.57461578785635, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(13, '2026-04-04 23:01:25.998657', -8.55344, 125.5224951, 211.54386471371024, 'terlambat', '', 1, NULL, NULL, NULL, 0),
(14, '2026-04-04 23:09:57.320359', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(15, '2026-04-04 23:18:46.395517', -8.5534152, 125.5228989, 167.24049903935142, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(16, '2026-04-04 23:25:19.368509', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(17, '2026-04-04 23:39:17.919557', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(18, '2026-04-04 23:43:56.201681', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(19, '2026-04-05 03:56:01.292207', -8.5534099, 125.522352, 227.40529971039717, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(20, '2026-04-05 03:58:49.136023', -8.5533836, 125.5231987, 134.57461578785635, 'hadir', '', 1, NULL, NULL, NULL, 0),
(21, '2026-04-05 04:15:50.458861', -8.5533836, 125.5231987, 134.57461578785635, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(22, '2026-04-05 04:22:05.252733', -8.5533836, 125.5231987, 134.57461578785635, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(23, '2026-04-05 04:22:49.819981', -8.5533836, 125.5231987, 134.57461578785635, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(24, '2026-04-05 04:27:38.265958', -8.5533477, 125.5235409, 97.71778072175235, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(25, '2026-04-05 04:35:34.400465', -8.5533477, 125.5235409, 97.71778072175235, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(26, '2026-04-05 04:40:07.209212', -8.5533477, 125.5235409, 97.71778072175235, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(27, '2026-04-05 04:44:44.786243', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(28, '2026-04-05 04:53:12.404743', -8.5533477, 125.5235409, 97.71778072175235, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(29, '2026-04-05 04:55:25.192780', -8.5533477, 125.5235409, 97.71778072175235, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(30, '2026-04-05 06:08:03.996156', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(31, '2026-04-05 06:15:13.985730', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(32, '2026-04-05 06:17:35.193543', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(33, '2026-04-05 06:21:33.584836', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(34, '2026-04-05 06:21:33.752225', -8.5536098, 125.522557, 205.03980444361935, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(35, '2026-04-05 07:09:09.988720', -8.5534196, 125.5228566, 171.86592628114198, 'alpha', 'Tidak melakukan absen keluar.', 2, NULL, NULL, NULL, 0),
(36, '2026-04-05 07:17:45.374867', -8.5534196, 125.5228566, 171.86592628114198, 'hadir_sebagian', 'Durasi kerja hanya 0j 9m (kurang dari 6 jam).', 2, '2026-04-05 07:26:53.325158', '2026-04-05 08:00:17.324682', '2026-04-05 08:00:27.288303', 0),
(37, '2026-04-07 19:58:39.541858', -8.553495, 125.524416, 0, 'izin', 'Aprova hosi Web Admin (Razaun: moras)', 2, '2026-04-08 09:00:00.000000', NULL, NULL, 0),
(38, '2026-04-07 19:58:39.546109', -8.553495, 125.524416, 0, 'izin', 'Aprova hosi Web Admin (Razaun: moras)', 2, '2026-04-09 09:00:00.000000', NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `api_violasaun_gps`
--

CREATE TABLE `api_violasaun_gps` (
  `id` bigint(20) NOT NULL,
  `tempu` datetime(6) NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `distansia_metru` double NOT NULL,
  `last_status` varchar(50) NOT NULL,
  `funsonariu_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 2, 'add_permission'),
(6, 'Can change permission', 2, 'change_permission'),
(7, 'Can delete permission', 2, 'delete_permission'),
(8, 'Can view permission', 2, 'view_permission'),
(9, 'Can add group', 3, 'add_group'),
(10, 'Can change group', 3, 'change_group'),
(11, 'Can delete group', 3, 'delete_group'),
(12, 'Can view group', 3, 'view_group'),
(13, 'Can add content type', 4, 'add_contenttype'),
(14, 'Can change content type', 4, 'change_contenttype'),
(15, 'Can delete content type', 4, 'delete_contenttype'),
(16, 'Can view content type', 4, 'view_contenttype'),
(17, 'Can add session', 5, 'add_session'),
(18, 'Can change session', 5, 'change_session'),
(19, 'Can delete session', 5, 'delete_session'),
(20, 'Can view session', 5, 'view_session'),
(21, 'Can add Pegawai', 6, 'add_pegawai'),
(22, 'Can change Pegawai', 6, 'change_pegawai'),
(23, 'Can delete Pegawai', 6, 'delete_pegawai'),
(24, 'Can view Pegawai', 6, 'view_pegawai'),
(25, 'Can add Absensi', 7, 'add_absensi'),
(26, 'Can change Absensi', 7, 'change_absensi'),
(27, 'Can delete Absensi', 7, 'delete_absensi'),
(28, 'Can view Absensi', 7, 'view_absensi'),
(29, 'Can add Konfigurasaun Sistema', 8, 'add_pengaturansistem'),
(30, 'Can change Konfigurasaun Sistema', 8, 'change_pengaturansistem'),
(31, 'Can delete Konfigurasaun Sistema', 8, 'delete_pengaturansistem'),
(32, 'Can view Konfigurasaun Sistema', 8, 'view_pengaturansistem'),
(33, 'Can add Pedidu Lisensa', 9, 'add_pengajuanizin'),
(34, 'Can change Pedidu Lisensa', 9, 'change_pengajuanizin'),
(35, 'Can delete Pedidu Lisensa', 9, 'delete_pengajuanizin'),
(36, 'Can view Pedidu Lisensa', 9, 'view_pengajuanizin'),
(37, 'Can add Hari Libur', 10, 'add_harilibur'),
(38, 'Can change Hari Libur', 10, 'change_harilibur'),
(39, 'Can delete Hari Libur', 10, 'delete_harilibur'),
(40, 'Can view Hari Libur', 10, 'view_harilibur'),
(41, 'Can add Funsonáriu', 6, 'add_funsonariu'),
(42, 'Can change Funsonáriu', 6, 'change_funsonariu'),
(43, 'Can delete Funsonáriu', 6, 'delete_funsonariu'),
(44, 'Can view Funsonáriu', 6, 'view_funsonariu'),
(45, 'Can add Presensa', 7, 'add_presensa'),
(46, 'Can change Presensa', 7, 'change_presensa'),
(47, 'Can delete Presensa', 7, 'delete_presensa'),
(48, 'Can view Presensa', 7, 'view_presensa'),
(49, 'Can add Pedidu Lisensa', 9, 'add_pedidulisensa'),
(50, 'Can change Pedidu Lisensa', 9, 'change_pedidulisensa'),
(51, 'Can delete Pedidu Lisensa', 9, 'delete_pedidulisensa'),
(52, 'Can view Pedidu Lisensa', 9, 'view_pedidulisensa'),
(53, 'Can add Konfigurasaun Sistema', 8, 'add_konfigurasaunsistema'),
(54, 'Can change Konfigurasaun Sistema', 8, 'change_konfigurasaunsistema'),
(55, 'Can delete Konfigurasaun Sistema', 8, 'delete_konfigurasaunsistema'),
(56, 'Can view Konfigurasaun Sistema', 8, 'view_konfigurasaunsistema'),
(57, 'Can add Loron Feriadu', 10, 'add_loronferiadu'),
(58, 'Can change Loron Feriadu', 10, 'change_loronferiadu'),
(59, 'Can delete Loron Feriadu', 10, 'delete_loronferiadu'),
(60, 'Can view Loron Feriadu', 10, 'view_loronferiadu'),
(61, 'Can add Violação Geofence', 11, 'add_violalokalizasaun'),
(62, 'Can change Violação Geofence', 11, 'change_violalokalizasaun'),
(63, 'Can delete Violação Geofence', 11, 'delete_violalokalizasaun'),
(64, 'Can view Violação Geofence', 11, 'view_violalokalizasaun');

-- --------------------------------------------------------

--
-- Table structure for table `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(1, '2026-04-04 21:00:09.007063', '2', 'admin002 - Vivencio', 1, '[{\"added\": {}}]', 6, 1);

-- --------------------------------------------------------

--
-- Table structure for table `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(1, 'admin', 'logentry'),
(6, 'api', 'funsonariu'),
(8, 'api', 'konfigurasaunsistema'),
(10, 'api', 'loronferiadu'),
(9, 'api', 'pedidulisensa'),
(7, 'api', 'presensa'),
(11, 'api', 'violalokalizasaun'),
(3, 'auth', 'group'),
(2, 'auth', 'permission'),
(4, 'contenttypes', 'contenttype'),
(5, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Table structure for table `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2026-04-04 20:54:07.220256'),
(2, 'api', '0001_initial', '2026-04-04 20:54:07.242154'),
(3, 'admin', '0001_initial', '2026-04-04 20:54:07.266578'),
(4, 'admin', '0002_logentry_remove_auto_add', '2026-04-04 20:54:07.269973'),
(5, 'admin', '0003_logentry_add_action_flag_choices', '2026-04-04 20:54:07.273683'),
(6, 'contenttypes', '0002_remove_content_type_name', '2026-04-04 20:54:07.287436'),
(7, 'auth', '0001_initial', '2026-04-04 20:54:07.336975'),
(8, 'auth', '0002_alter_permission_name_max_length', '2026-04-04 20:54:07.350001'),
(9, 'auth', '0003_alter_user_email_max_length', '2026-04-04 20:54:07.353422'),
(10, 'auth', '0004_alter_user_username_opts', '2026-04-04 20:54:07.356942'),
(11, 'auth', '0005_alter_user_last_login_null', '2026-04-04 20:54:07.360532'),
(12, 'auth', '0006_require_contenttypes_0002', '2026-04-04 20:54:07.362189'),
(13, 'auth', '0007_alter_validators_add_error_messages', '2026-04-04 20:54:07.365717'),
(14, 'auth', '0008_alter_user_username_max_length', '2026-04-04 20:54:07.368934'),
(15, 'auth', '0009_alter_user_last_name_max_length', '2026-04-04 20:54:07.372951'),
(16, 'auth', '0010_alter_group_name_max_length', '2026-04-04 20:54:07.379409'),
(17, 'auth', '0011_update_proxy_permissions', '2026-04-04 20:54:07.384653'),
(18, 'auth', '0012_alter_user_first_name_max_length', '2026-04-04 20:54:07.388394'),
(19, 'sessions', '0001_initial', '2026-04-04 20:54:07.396433'),
(20, 'api', '0002_alter_absensi_status_alter_absensi_waktu_masuk_and_more', '2026-04-04 22:02:59.723781'),
(21, 'api', '0003_absensi_waktu_keluar', '2026-04-04 23:32:10.959047'),
(22, 'api', '0004_alter_absensi_status', '2026-04-05 07:03:03.247879'),
(23, 'api', '0005_absensi_waktu_keluar_istirahat_and_more', '2026-04-05 07:36:23.182708'),
(24, 'api', '0006_rename_fields', '2026-04-07 17:55:32.821332'),
(25, 'api', '0007_pengaturansistem_alter_absensi_options_and_more', '2026-04-07 18:57:26.752296'),
(26, 'api', '0008_harilibur_pengaturansistem_tarif_lembur_per_jam_and_more', '2026-04-07 19:42:32.428400'),
(27, 'api', '0009_pengaturansistem_last_message_and_more', '2026-04-07 20:04:52.176898'),
(28, 'api', '0010_alter_harilibur_options_alter_pegawai_options_and_more', '2026-04-07 20:59:47.345046'),
(29, 'api', '0011_pedidulisensa_presensa_and_more', '2026-04-07 21:38:27.778227'),
(30, 'api', '0012_alter_pedidulisensa_funsonariu_and_more', '2026-04-07 21:40:41.078802'),
(31, 'api', '0013_remove_konfigurasaunsistema_tarif_lembur_per_jam', '2026-04-07 21:46:02.536824'),
(32, 'api', '0014_violalokalizasaun', '2026-04-07 21:51:36.402555');

-- --------------------------------------------------------

--
-- Table structure for table `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `django_session`
--

INSERT INTO `django_session` (`session_key`, `session_data`, `expire_date`) VALUES
('06qyu50bvd7h292qaofsac5ilutuff33', '.eJxVjEEOwiAQRe_C2hAYwE5duu8ZyMCAVA0kpV0Z765NutDtf-_9l_C0rcVvPS1-ZnERWpx-t0DxkeoO-E711mRsdV3mIHdFHrTLqXF6Xg_376BQL9_6zGBwGA2q0USTQDun2BpLNlmbjXMZEysIgMhkCbSGQBjBqaxgUFm8P7G6Ns4:1w9IHR:alAPCWih75t3eve867_0Ioh9Xfde8hY8F0X1h73zR1c', '2026-04-19 07:52:25.396560'),
('8c7bxuxwh531ij1e4tm41c4yg3lj2cnx', '.eJxVjEEOwiAQRe_C2hAYwE5duu8ZyMCAVA0kpV0Z765NutDtf-_9l_C0rcVvPS1-ZnERWpx-t0DxkeoO-E711mRsdV3mIHdFHrTLqXF6Xg_376BQL9_6zGBwGA2q0USTQDun2BpLNlmbjXMZEysIgMhkCbSGQBjBqaxgUFm8P7G6Ns4:1w98HY:Lk4YnFMekVh5FP0_uSnZUy4ja0zO3HNEKAXwYJzY5Mg', '2026-04-18 21:11:52.121501'),
('jtgtduw32wnpxxyd1di6j2ukw70sw77w', '.eJxVjEEOwiAQRe_C2hAYwE5duu8ZyMCAVA0kpV0Z765NutDtf-_9l_C0rcVvPS1-ZnERWpx-t0DxkeoO-E711mRsdV3mIHdFHrTLqXF6Xg_376BQL9_6zGBwGA2q0USTQDun2BpLNlmbjXMZEysIgMhkCbSGQBjBqaxgUFm8P7G6Ns4:1w9APJ:S3AQve47yHExQYGkuHQ5oeEJUqdKl1faNPKpuj66xME', '2026-04-18 23:28:01.899641'),
('ooqwxveaute9tficwbius3tkh6llmppb', '.eJxVjEEOwiAQRe_C2hAYwE5duu8ZyMCAVA0kpV0Z765NutDtf-_9l_C0rcVvPS1-ZnERWpx-t0DxkeoO-E711mRsdV3mIHdFHrTLqXF6Xg_376BQL9_6zGBwGA2q0USTQDun2BpLNlmbjXMZEysIgMhkCbSGQBjBqaxgUFm8P7G6Ns4:1wAX3b:PSpleaBW_N-WlgvPEQwuVhNOZGXIK5UeUGUCy-e76bQ', '2026-04-22 17:51:15.376489'),
('xlrrmsupt5ezk3uq37euwsvd8umvjp0q', '.eJxVjEEOwiAQRe_C2hAYwE5duu8ZyMCAVA0kpV0Z765NutDtf-_9l_C0rcVvPS1-ZnERWpx-t0DxkeoO-E711mRsdV3mIHdFHrTLqXF6Xg_376BQL9_6zGBwGA2q0USTQDun2BpLNlmbjXMZEysIgMhkCbSGQBjBqaxgUFm8P7G6Ns4:1wA9Jv:XJnO7q0Arnc3s2Fw_AZcXuDQ00Bx_Cg8moV7qCyvSps', '2026-04-21 16:30:31.127995');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `api_funsonariu`
--
ALTER TABLE `api_funsonariu`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nik` (`nre`),
  ADD KEY `api_pegawai_unit_kerja_3fa57354` (`unidade_traballu`);

--
-- Indexes for table `api_konfigurasaun_sistema`
--
ALTER TABLE `api_konfigurasaun_sistema`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `api_loron_feriadu`
--
ALTER TABLE `api_loron_feriadu`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tanggal` (`tanggal`);

--
-- Indexes for table `api_pedidu_lisensa`
--
ALTER TABLE `api_pedidu_lisensa`
  ADD PRIMARY KEY (`id`),
  ADD KEY `api_pedidu_lisensa_funsonariu_id_97183aaf_fk_api_funsonariu_id` (`funsonariu_id`);

--
-- Indexes for table `api_presensa`
--
ALTER TABLE `api_presensa`
  ADD PRIMARY KEY (`id`),
  ADD KEY `api_absensi_status_1eb34e28` (`status`),
  ADD KEY `api_absensi_waktu_masuk_d197d7f4` (`tempu_tama`),
  ADD KEY `api_presensa_funsonariu_id_c82cbf14_fk_api_funsonariu_id` (`funsonariu_id`);

--
-- Indexes for table `api_violasaun_gps`
--
ALTER TABLE `api_violasaun_gps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `api_violasaun_gps_funsonariu_id_fb19b9f0_fk_api_funsonariu_id` (`funsonariu_id`);

--
-- Indexes for table `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indexes for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indexes for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_api_funsonariu_id` (`user_id`);

--
-- Indexes for table `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indexes for table `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `api_funsonariu`
--
ALTER TABLE `api_funsonariu`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `api_konfigurasaun_sistema`
--
ALTER TABLE `api_konfigurasaun_sistema`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `api_loron_feriadu`
--
ALTER TABLE `api_loron_feriadu`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `api_pedidu_lisensa`
--
ALTER TABLE `api_pedidu_lisensa`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `api_presensa`
--
ALTER TABLE `api_presensa`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `api_violasaun_gps`
--
ALTER TABLE `api_violasaun_gps`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `api_pedidu_lisensa`
--
ALTER TABLE `api_pedidu_lisensa`
  ADD CONSTRAINT `api_pedidu_lisensa_funsonariu_id_97183aaf_fk_api_funsonariu_id` FOREIGN KEY (`funsonariu_id`) REFERENCES `api_funsonariu` (`id`);

--
-- Constraints for table `api_presensa`
--
ALTER TABLE `api_presensa`
  ADD CONSTRAINT `api_presensa_funsonariu_id_c82cbf14_fk_api_funsonariu_id` FOREIGN KEY (`funsonariu_id`) REFERENCES `api_funsonariu` (`id`);

--
-- Constraints for table `api_violasaun_gps`
--
ALTER TABLE `api_violasaun_gps`
  ADD CONSTRAINT `api_violasaun_gps_funsonariu_id_fb19b9f0_fk_api_funsonariu_id` FOREIGN KEY (`funsonariu_id`) REFERENCES `api_funsonariu` (`id`);

--
-- Constraints for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Constraints for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Constraints for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_api_funsonariu_id` FOREIGN KEY (`user_id`) REFERENCES `api_funsonariu` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
