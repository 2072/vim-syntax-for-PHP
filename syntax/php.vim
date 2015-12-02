" Vim syntax file
" Language: php PHP 5
" Maintainer: John Wellesz (john DOT wellesz AT teaser DOT FR)
" Last Change: 2014-04-24
" URL: https://github.com/2072/vim-syntax-for-PHP
" Former Maintainers: Jason Woofenden <jason@jasonwoof.com>,
"         Peter Hodge <toomuchphp-vim@yahoo.com>,
"         Debian VIM Maintainers <pkg-vim-maintainers@lists.alioth.debian.org>
"
" This is a fork of https://gitorious.org/jasonwoof/vim-syntax/blobs/master/php.vim as it was on 2013-08-28
"
" Note: If you are using a colour terminal with dark background, you will probably find
"       the 'elflord' colorscheme is much better for PHP's syntax than the default
"       colourscheme, because elflord's colours will better highlight the break-points
"       (Statements) in your code.
"
" Options:  php_sql_query = 1  for SQL syntax highlighting inside strings
"           php_htmlInStrings = 1  for HTML syntax highlighting inside strings
"           php_baselib = 1  for highlighting baselib functions
"           php_asp_tags = 1  for highlighting ASP-style short tags
"           php_parent_error_close = 1  for highlighting parent error ] or )
"           php_parent_error_open = 1  for skipping an php end tag, if there exists an open ( or [ without a closing one
"           php_oldStyle = 1  for using old colorstyle
"           php_noShortTags = 1  don't sync <? ?> as php
"           php_folding = 1  for folding classes and functions
"           php_folding = 2  for folding all { } regions
"           php_sync_method = x
"                             x=-1 to sync by search ( default )
"                             x>0 to sync at least x lines backwards
"                             x=0 to sync from start
"
"       Added by Peter Hodge On June 9, 2006:
"           php_special_functions = 1|0 to highlight functions with abnormal behaviour
"           php_alt_comparisons = 1|0 to highlight comparison operators in an alternate colour
"           php_alt_assignByReference = 1|0 to highlight '= &' in an alternate colour
"
"           Note: these all default to 1 (On), so you would set them to '0' to turn them off.
"                 E.g., in your .vimrc or _vimrc file:
"                   let php_special_functions = 0
"                   let php_alt_comparisons = 0
"                   let php_alt_assignByReference = 0
"                 Unletting these variables will revert back to their default (On).
"
"
" Note:
" Setting php_folding=1 will match a closing } by comparing the indent
" before the class or function keyword with the indent of a matching }.
" Setting php_folding=2 will match all of pairs of {,} ( see known
" bugs ii )

" Known Bugs:
"  - setting  php_parent_error_close  on  and  php_parent_error_open  off
"    has these two leaks:
"     i) A closing ) or ] inside a string match to the last open ( or [
"        before the string, when the the closing ) or ] is on the same line
"        where the string started. In this case a following ) or ] after
"        the string would be highlighted as an error, what is incorrect.
"    ii) Same problem if you are setting php_folding = 2 with a closing
"        } inside an string on the first line of this string.

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let g:main_syntax = 'php'
endif

if search('^?>', 'nw') != 0
  if version < 600
    unlet! php_folding
    if exists("php_sync_method") && !php_sync_method
      let g:php_sync_method=-1
    endif
    so <sfile>:p:h/html.vim
  else
    runtime! syntax/html.vim
    unlet b:current_syntax
  endif
endif

" accept old options
if !exists("php_sync_method")
  if exists("php_minlines")
    let g:php_sync_method=php_minlines
  else
    let g:php_sync_method=-1
  endif
endif

if exists("php_parentError") && !exists("php_parent_error_open") && !exists("php_parent_error_close")
  let g:php_parent_error_close=1
  let g:php_parent_error_open=1
endif

syn cluster htmlPreproc add=phpRegion,phpRegionAsp,phpRegionSc

if version < 600
  syn include @sqlTop <sfile>:p:h/sql.vim
else
  syn include @sqlTop syntax/sql.vim
endif
syn sync clear
unlet b:current_syntax
syn cluster sqlTop remove=sqlString,sqlComment
if exists( "php_sql_query")
  syn cluster phpAddStrings contains=@sqlTop
endif

if exists( "php_htmlInStrings")
  syn cluster phpAddStrings add=@htmlTop
endif

" make sure we can use \ at the begining of the line to do a continuation
let s:cpo_save = &cpo
set cpo&vim

syn case match

" Env Variables
syn keyword phpEnvVar GATEWAY_INTERFACE SERVER_NAME SERVER_SOFTWARE SERVER_PROTOCOL REQUEST_METHOD QUERY_STRING DOCUMENT_ROOT HTTP_ACCEPT HTTP_ACCEPT_CHARSET HTTP_ENCODING HTTP_ACCEPT_LANGUAGE HTTP_CONNECTION HTTP_HOST HTTP_REFERER HTTP_USER_AGENT REMOTE_ADDR REMOTE_PORT SCRIPT_FILENAME SERVER_ADMIN SERVER_PORT SERVER_SIGNATURE PATH_TRANSLATED SCRIPT_NAME REQUEST_URI contained

" Internal Variables
syn keyword phpIntVar GLOBALS PHP_ERRMSG PHP_SELF HTTP_GET_VARS HTTP_POST_VARS HTTP_COOKIE_VARS HTTP_POST_FILES HTTP_ENV_VARS HTTP_SERVER_VARS HTTP_SESSION_VARS HTTP_RAW_POST_DATA HTTP_STATE_VARS _GET _POST _COOKIE _FILES _SERVER _ENV _SERVER _REQUEST _SESSION  contained

" Constants
syn keyword phpCoreConstant PHP_VERSION PHP_OS DEFAULT_INCLUDE_PATH PEAR_INSTALL_DIR PEAR_EXTENSION_DIR PHP_EXTENSION_DIR PHP_BINDIR PHP_LIBDIR PHP_DATADIR PHP_SYSCONFDIR PHP_LOCALSTATEDIR PHP_CONFIG_FILE_PATH PHP_OUTPUT_HANDLER_START PHP_OUTPUT_HANDLER_CONT PHP_OUTPUT_HANDLER_END contained

" Predefined constants
" Generated by: curl -q http://php.net/manual/en/errorfunc.constants.php | grep -oP 'E_\w+' | sort -u
syn keyword phpCoreConstant E_ALL E_COMPILE_ERROR E_COMPILE_WARNING E_CORE_ERROR E_CORE_WARNING E_DEPRECATED E_ERROR E_NOTICE E_PARSE E_RECOVERABLE_ERROR E_STRICT E_USER_DEPRECATED E_USER_ERROR E_USER_NOTICE E_USER_WARNING E_WARNING contained

syn keyword phpConstant  __LINE__ __FILE__ __FUNCTION__ __METHOD__ __CLASS__ __DIR__ __NAMESPACE__  contained

syn case ignore


" Function and Methods ripped from php_manual_en.tar.gz Dec 2015
" Generated by non-expert commands:
" awk '{ match($0, /<span class=\"methodname\"><strong>([^<]*)</, arr)
" if (arr[1])
"   print arr[1]
"   }' * > php_functions_list.txt
"
"   cat php_functions_list.txt | /usr/bin/grep :: | awk '{ match($0, /[^:]*::([^(]*)/, arr)
"   if (arr[1])
"     print arr[1]
"     }' | sort -u > php_methods.txt
"
"     cat php_functions_list.txt | /usr/bin/grep -v :: | awk '{ match($0, /([^_]{2}\w*)/, arr)
"     if (arr[1])
"       print arr[1]
"       }' | sort -u > php_functions.txt])) }'
"
syn keyword phpFunctions  abs acos acosh addcslashes addFill addslashes addTaskBackground apache_child_terminate apache_getenv apache_get_modules apache_get_version apache_lookup_uri apache_note apache_request_headers apache_reset_timeout apache_response_headers apache_setenv apc_add apc_bin_dump apc_bin_dumpfile  contained
syn keyword phpFunctions  apc_bin_load apc_bin_loadfile apc_cache_info apc_cas apc_clear_cache apc_compile_file apc_dec apc_define_constants apc_delete apc_delete_file apc_exists apc_fetch apc_inc apc_load_constants apc_sma_info apc_store apcu_add apcu_cache_info apcu_cas apcu_clear_cache  contained
syn keyword phpFunctions  apcu_dec apcu_delete apcu_entry apcu_exists apcu_fetch apcu_inc apcu_sma_info apcu_store apd_breakpoint apd_callstack apd_clunk apd_continue apd_croak apd_dump_function_table apd_dump_persistent_resources apd_dump_regular_resources apd_echo apd_get_active_symbols apd_set_pprof_trace apd_set_session  contained
syn keyword phpFunctions  apd_set_session_trace apd_set_session_trace_socket AppendIterator array array_change_key_case array_chunk array_column array_combine array_count_values array_diff array_diff_assoc array_diff_key array_diff_uassoc array_diff_ukey array_fill array_fill_keys array_filter array_flip array_intersect array_intersect_assoc  contained
syn keyword phpFunctions  array_intersect_key array_intersect_uassoc array_intersect_ukey array_key_exists array_keys array_map array_merge array_merge_recursive array_multisort array_pad array_pop array_product array_push array_rand array_reduce array_replace array_replace_recursive array_reverse array_search array_shift  contained
syn keyword phpFunctions  array_slice array_splice array_sum array_udiff array_udiff_assoc array_udiff_uassoc array_uintersect array_uintersect_assoc array_uintersect_uassoc array_unique array_unshift array_values array_walk array_walk_recursive arsort asin asinh asort assert assert_options  contained
syn keyword phpFunctions  atan atan2 atanh autoload base64_decode base64_encode base_convert basename bbcode_add_element bbcode_add_smiley bbcode_create bbcode_destroy bbcode_parse bbcode_set_arg_parser bbcode_set_flags bcadd bccomp bcdiv bcmod bcmul  contained
syn keyword phpFunctions  bcompiler_load bcompiler_load_exe bcompiler_parse_class bcompiler_read bcompiler_write_class bcompiler_write_constant bcompiler_write_exe_footer bcompiler_write_file bcompiler_write_footer bcompiler_write_function bcompiler_write_functions_from_file bcompiler_write_header bcompiler_write_included_filename bcpow bcpowmod bcscale bcsqrt bcsub bin2hex bindec  contained
syn keyword phpFunctions  bindtextdomain bind_textdomain_codeset blenc_encrypt boolval bson_decode bson_encode bsonSerialize bsonUnserialize bzclose bzcompress bzdecompress bzerrno bzerror bzerrstr bzflush bzopen bzread bzwrite cairo_append_path cairo_arc  contained
syn keyword phpFunctions  cairo_arc_negative cairo_available_fonts cairo_available_surfaces cairo_clip cairo_clip_extents cairo_clip_preserve cairo_clip_rectangle_list cairo_close_path CairoContent cairo_copy_page cairo_copy_path cairo_copy_path_flat cairo_create cairo_curve_to cairo_device_to_user cairo_device_to_user_distance cairo_fill cairo_fill_extents cairo_fill_preserve cairo_font_extents  contained
syn keyword phpFunctions  cairo_font_face_get_type cairo_font_face_status cairo_font_options_create cairo_font_options_equal cairo_font_options_get_antialias cairo_font_options_get_hint_metrics cairo_font_options_get_hint_style cairo_font_options_get_subpixel_order cairo_font_options_hash cairo_font_options_merge cairo_font_options_set_antialias cairo_font_options_set_hint_metrics cairo_font_options_set_hint_style cairo_font_options_set_subpixel_order cairo_font_options_status cairo_format_stride_for_width cairo_get_antialias cairo_get_current_point cairo_get_dash cairo_get_dash_count  contained
syn keyword phpFunctions  cairo_get_fill_rule cairo_get_font_face cairo_get_font_matrix cairo_get_font_options cairo_get_group_target cairo_get_line_cap cairo_get_line_join cairo_get_line_width cairo_get_matrix cairo_get_miter_limit cairo_get_operator cairo_get_scaled_font cairo_get_source cairo_get_target cairo_get_tolerance cairo_glyph_path cairo_has_current_point cairo_identity_matrix cairo_image_surface_create cairo_image_surface_create_for_data  contained
syn keyword phpFunctions  cairo_image_surface_create_from_png cairo_image_surface_get_data cairo_image_surface_get_format cairo_image_surface_get_height cairo_image_surface_get_stride cairo_image_surface_get_width cairo_in_fill cairo_in_stroke cairo_line_to cairo_mask cairo_mask_surface cairo_matrix_init cairo_matrix_init_identity cairo_matrix_init_rotate cairo_matrix_init_scale cairo_matrix_init_translate cairo_matrix_invert cairo_matrix_multiply cairo_matrix_rotate cairo_matrix_scale  contained
syn keyword phpFunctions  cairo_matrix_transform_distance cairo_matrix_transform_point cairo_matrix_translate cairo_move_to cairo_new_path cairo_new_sub_path cairo_paint cairo_paint_with_alpha cairo_path_extents cairo_pattern_add_color_stop_rgb cairo_pattern_add_color_stop_rgba cairo_pattern_create_for_surface cairo_pattern_create_linear cairo_pattern_create_radial cairo_pattern_create_rgb cairo_pattern_create_rgba cairo_pattern_get_color_stop_count cairo_pattern_get_color_stop_rgba cairo_pattern_get_extend cairo_pattern_get_filter  contained
syn keyword phpFunctions  cairo_pattern_get_linear_points cairo_pattern_get_matrix cairo_pattern_get_radial_circles cairo_pattern_get_rgba cairo_pattern_get_surface cairo_pattern_get_type cairo_pattern_set_extend cairo_pattern_set_filter cairo_pattern_set_matrix cairo_pattern_status cairo_pdf_surface_create cairo_pdf_surface_set_size cairo_pop_group cairo_pop_group_to_source cairo_ps_get_levels cairo_ps_level_to_string cairo_ps_surface_create cairo_ps_surface_dsc_begin_page_setup cairo_ps_surface_dsc_begin_setup cairo_ps_surface_dsc_comment  contained
syn keyword phpFunctions  cairo_ps_surface_get_eps cairo_ps_surface_restrict_to_level cairo_ps_surface_set_eps cairo_ps_surface_set_size cairo_push_group cairo_push_group_with_content cairo_rectangle cairo_rel_curve_to cairo_rel_line_to cairo_rel_move_to cairo_reset_clip cairo_restore cairo_rotate cairo_save cairo_scale cairo_scaled_font_create cairo_scaled_font_extents cairo_scaled_font_get_ctm cairo_scaled_font_get_font_face cairo_scaled_font_get_font_matrix  contained
syn keyword phpFunctions  cairo_scaled_font_get_font_options cairo_scaled_font_get_scale_matrix cairo_scaled_font_get_type cairo_scaled_font_glyph_extents cairo_scaled_font_status cairo_scaled_font_text_extents cairo_select_font_face cairo_set_antialias cairo_set_dash cairo_set_fill_rule cairo_set_font_face cairo_set_font_matrix cairo_set_font_options cairo_set_font_size cairo_set_line_cap cairo_set_line_join cairo_set_line_width cairo_set_matrix cairo_set_miter_limit cairo_set_operator  contained
syn keyword phpFunctions  cairo_set_scaled_font cairo_set_source cairo_set_source_surface cairo_set_tolerance cairo_show_page cairo_show_text cairo_status cairo_status_to_string cairo_stroke cairo_stroke_extents cairo_stroke_preserve cairo_surface_copy_page cairo_surface_create_similar cairo_surface_finish cairo_surface_flush cairo_surface_get_content cairo_surface_get_device_offset cairo_surface_get_font_options cairo_surface_get_type cairo_surface_mark_dirty  contained
syn keyword phpFunctions  cairo_surface_mark_dirty_rectangle cairo_surface_set_device_offset cairo_surface_set_fallback_resolution cairo_surface_show_page cairo_surface_status cairo_surface_write_to_png cairo_svg_get_versions cairo_svg_surface_create cairo_svg_surface_restrict_to_version cairo_svg_version_to_string cairo_text_extents cairo_text_path cairo_transform cairo_translate cairo_user_to_device cairo_user_to_device_distance cairo_version cairo_version_string calculhmac calcul_hmac  contained
syn keyword phpFunctions  cal_days_in_month cal_from_jd cal_info call callback callStatic call_user_func call_user_func_array call_user_method call_user_method_array cal_to_jd ceil chdb_create chdir checkdate checkdnsrr checkstatus chgrp chmod chown  contained
syn keyword phpFunctions  chr chroot chunk_split class_alias class_exists class_implements classkit_import classkit_method_add classkit_method_copy classkit_method_redefine classkit_method_remove classkit_method_rename class_parents class_uses clearstatcache cli_get_process_title cli_set_process_title clone closedir closelog  contained
syn keyword phpFunctions  collator_asort collator_compare collator_create collator_get_attribute collator_get_error_code collator_get_error_message collator_get_locale collator_get_sort_key collator_get_strength collator_set_attribute collator_set_strength collator_sort collator_sort_with_sort_keys com_create_guid com_event_sink com_get_active_object com_load_typelib com_message_pump compact completeauthorizations  contained
syn keyword phpFunctions  com_print_typeinfo connect connection_aborted connectionerror connection_status constant construct Context convert_cyr_string convert_uudecode convert_uuencode copy cos cosh count count_chars counter_bump counter_bump_value counter_create counter_get  contained
syn keyword phpFunctions  counter_get_meta counter_get_value counter_reset counter_reset_value crack_check crack_closedict crack_getlastmessage crack_opendict crc32 create_function crypt ctype_alnum ctype_alpha ctype_cntrl ctype_digit ctype_graph ctype_lower ctype_print ctype_punct ctype_space  contained
syn keyword phpFunctions  ctype_upper ctype_xdigit cubrid_affected_rows cubrid_bind cubrid_client_encoding cubrid_close cubrid_close_prepare cubrid_close_request cubrid_col_get cubrid_col_size cubrid_column_names cubrid_column_types cubrid_commit cubrid_connect cubrid_connect_with_url cubrid_current_oid cubrid_data_seek cubrid_db_name cubrid_disconnect cubrid_drop  contained
syn keyword phpFunctions  cubrid_errno cubrid_error cubrid_error_code cubrid_error_code_facility cubrid_error_msg cubrid_execute cubrid_fetch cubrid_fetch_array cubrid_fetch_assoc cubrid_fetch_field cubrid_fetch_lengths cubrid_fetch_object cubrid_fetch_row cubrid_field_flags cubrid_field_len cubrid_field_name cubrid_field_seek cubrid_field_table cubrid_field_type cubrid_free_result  contained
syn keyword phpFunctions  cubrid_get cubrid_get_autocommit cubrid_get_charset cubrid_get_class_name cubrid_get_client_info cubrid_get_db_parameter cubrid_get_query_timeout cubrid_get_server_info cubrid_insert_id cubrid_is_instance cubrid_list_dbs cubrid_load_from_glo cubrid_lob2_bind cubrid_lob2_close cubrid_lob2_export cubrid_lob2_import cubrid_lob2_new cubrid_lob2_read cubrid_lob2_seek cubrid_lob2_seek64  contained
syn keyword phpFunctions  cubrid_lob2_size cubrid_lob2_size64 cubrid_lob2_tell cubrid_lob2_tell64 cubrid_lob2_write cubrid_lob_close cubrid_lob_export cubrid_lob_get cubrid_lob_send cubrid_lob_size cubrid_lock_read cubrid_lock_write cubrid_move_cursor cubrid_new_glo cubrid_next_result cubrid_num_cols cubrid_num_fields cubrid_num_rows cubrid_pconnect cubrid_pconnect_with_url  contained
syn keyword phpFunctions  cubrid_ping cubrid_prepare cubrid_put cubrid_query cubrid_real_escape_string cubrid_result cubrid_rollback cubrid_save_to_glo cubrid_schema cubrid_send_glo cubrid_seq_drop cubrid_seq_insert cubrid_seq_put cubrid_set_add cubrid_set_autocommit cubrid_set_db_parameter cubrid_set_drop cubrid_set_query_timeout cubrid_unbuffered_query cubrid_version  contained
syn keyword phpFunctions  curl_close curl_copy_handle curl_errno curl_error curl_escape curl_exec curl_file_create curl_getinfo curl_init curl_multi_add_handle curl_multi_close curl_multi_exec curl_multi_getcontent curl_multi_info_read curl_multi_init curl_multi_remove_handle curl_multi_select curl_multi_setopt curl_multi_strerror curl_pause  contained
syn keyword phpFunctions  curl_reset curl_setopt curl_setopt_array curl_share_close curl_share_init curl_share_setopt curl_strerror curl_unescape curl_version current cyrus_authenticate cyrus_bind cyrus_close cyrus_connect cyrus_query cyrus_unbind date date_default_timezone_get date_default_timezone_set datefmt_create  contained
syn keyword phpFunctions  datefmt_format datefmt_format_object datefmt_get_calendar datefmt_get_calendar_object datefmt_get_datetype datefmt_get_error_code datefmt_get_error_message datefmt_get_locale datefmt_get_pattern datefmt_get_timetype datefmt_get_timezone datefmt_get_timezone_id datefmt_is_lenient datefmt_localtime datefmt_parse datefmt_set_calendar datefmt_set_lenient datefmt_set_pattern datefmt_set_timezone datefmt_set_timezone_id  contained
syn keyword phpFunctions  date_parse date_parse_from_format date_sun_info date_sunrise date_sunset DateTime db2_autocommit db2_bind_param db2_client_info db2_close db2_column_privileges db2_columns db2_commit db2_connect db2_conn_error db2_conn_errormsg db2_cursor_type db2_escape_string db2_exec db2_execute  contained
syn keyword phpFunctions  db2_fetch_array db2_fetch_assoc db2_fetch_both db2_fetch_object db2_fetch_row db2_field_display_size db2_field_name db2_field_num db2_field_precision db2_field_scale db2_field_type db2_field_width db2_foreign_keys db2_free_result db2_free_stmt db2_get_option db2_last_insert_id db2_lob_read db2_next_result db2_num_fields  contained
syn keyword phpFunctions  db2_num_rows db2_pclose db2_pconnect db2_prepare db2_primary_keys db2_procedure_columns db2_procedures db2_result db2_rollback db2_server_info db2_set_option db2_special_columns db2_statistics db2_stmt_error db2_stmt_errormsg db2_table_privileges db2_tables dba_close dba_delete dba_exists  contained
syn keyword phpFunctions  dba_fetch dba_firstkey dba_handlers dba_insert dba_key_split dba_list dba_nextkey dba_open dba_optimize dba_popen dba_replace dbase_add_record dbase_close dbase_create dbase_delete_record dbase_get_header_info dbase_get_record dbase_get_record_with_names dbase_numfields dbase_numrecords  contained
syn keyword phpFunctions  dbase_open dbase_pack dbase_replace_record dba_sync dbplus_add dbplus_aql dbplus_chdir dbplus_close dbplus_curr dbplus_errcode dbplus_errno dbplus_find dbplus_first dbplus_flush dbplus_freealllocks dbplus_freelock dbplus_freerlocks dbplus_getlock dbplus_getunique dbplus_info  contained
syn keyword phpFunctions  dbplus_last dbplus_lockrel dbplus_next dbplus_open dbplus_prev dbplus_rchperm dbplus_rcreate dbplus_rcrtexact dbplus_rcrtlike dbplus_resolve dbplus_restorepos dbplus_rkeys dbplus_ropen dbplus_rquery dbplus_rrename dbplus_rsecindex dbplus_runlink dbplus_rzap dbplus_savepos dbplus_setindex  contained
syn keyword phpFunctions  dbplus_setindexbynumber dbplus_sql dbplus_tcl dbplus_tremove dbplus_undo dbplus_undoprepare dbplus_unlockrel dbplus_unselect dbplus_update dbplus_xlockrel dbplus_xunlockrel dbx_close dbx_compare dbx_connect dbx_error dbx_escape_string dbx_fetch_row dbx_query dbx_sort dcgettext  contained
syn keyword phpFunctions  dcngettext debug_backtrace debugInfo debug_print_backtrace debug_zval_dump decbin dechex decoct define defined define_syslog_variables deg2rad deletetrans destroyconn destroyengine destruct dgettext dio_close dio_fcntl dio_open  contained
syn keyword phpFunctions  dio_read dio_seek dio_stat dio_tcsetattr dio_truncate dio_write dir dirname disk_free_space disk_total_space dl dngettext dns_get_record dom_import_simplexml each easter_date easter_days echo eio_busy eio_cancel  contained
syn keyword phpFunctions  eio_chmod eio_chown eio_close eio_custom eio_dup2 eio_event_loop eio_fallocate eio_fchmod eio_fchown eio_fdatasync eio_fstat eio_fstatvfs eio_fsync eio_ftruncate eio_futime eio_get_event_stream eio_get_last_error eio_grp eio_grp_add eio_grp_cancel  contained
syn keyword phpFunctions  eio_grp_limit eio_init eio_link eio_lstat eio_mkdir eio_mknod eio_nop eio_npending eio_nready eio_nreqs eio_nthreads eio_open eio_poll eio_read eio_readahead eio_readdir eio_readlink eio_realpath eio_rename eio_rmdir  contained
syn keyword phpFunctions  eio_seek eio_sendfile eio_set_max_idle eio_set_max_parallel eio_set_max_poll_reqs eio_set_max_poll_time eio_set_min_parallel eio_stat eio_statvfs eio_symlink eio_sync eio_sync_file_range eio_syncfs eio_truncate eio_unlink eio_utime eio_write empty enchant_broker_describe enchant_broker_dict_exists  contained
syn keyword phpFunctions  enchant_broker_free enchant_broker_free_dict enchant_broker_get_dict_path enchant_broker_get_error enchant_broker_init enchant_broker_list_dicts enchant_broker_request_dict enchant_broker_request_pwl_dict enchant_broker_set_dict_path enchant_broker_set_ordering enchant_dict_add_to_personal enchant_dict_add_to_session enchant_dict_check enchant_dict_describe enchant_dict_get_error enchant_dict_is_in_session enchant_dict_quick_check enchant_dict_store_replacement enchant_dict_suggest end  contained
syn keyword phpFunctions  ereg eregi eregi_replace ereg_replace error_clear_last error_get_last error_log error_reporting escapeshellarg escapeshellcmd eval event_base_free event_base_loop event_base_loopbreak event_base_loopexit event_base_new event_base_priority_init event_base_reinit event_base_set event_buffer_base_set  contained
syn keyword phpFunctions  event_buffer_disable event_buffer_enable event_buffer_fd_set event_buffer_free event_buffer_new event_buffer_priority_set event_buffer_read event_buffer_set_callback event_buffer_timeout_set event_buffer_watermark_set event_buffer_write event_new event_priority_set event_timer_set EvPrepare exec exif_imagetype exif_read_data exif_tagname exif_thumbnail  contained
syn keyword phpFunctions  exit exp expect_expectl expect_popen explode expm1 extension_loaded extract ezmlm_hash fam_cancel_monitor fam_close fam_monitor_collection fam_monitor_directory fam_monitor_file fam_next_event fam_open fam_pending fam_resume_monitor fam_suspend_monitor fann_cascadetrain_on_data  contained
syn keyword phpFunctions  fann_cascadetrain_on_file fann_clear_scaling_params fann_copy fann_create_from_file fann_create_shortcut fann_create_shortcut_array fann_create_sparse fann_create_sparse_array fann_create_standard fann_create_standard_array fann_create_train fann_create_train_from_callback fann_descale_input fann_descale_output fann_descale_train fann_destroy fann_destroy_train fann_duplicate_train_data fann_get_activation_function fann_get_activation_steepness  contained
syn keyword phpFunctions  fann_get_bias_array fann_get_bit_fail fann_get_bit_fail_limit fann_get_cascade_activation_functions fann_get_cascade_activation_functions_count fann_get_cascade_activation_steepnesses fann_get_cascade_activation_steepnesses_count fann_get_cascade_candidate_change_fraction fann_get_cascade_candidate_limit fann_get_cascade_candidate_stagnation_epochs fann_get_cascade_max_cand_epochs fann_get_cascade_max_out_epochs fann_get_cascade_min_cand_epochs fann_get_cascade_min_out_epochs fann_get_cascade_num_candidate_groups fann_get_cascade_num_candidates fann_get_cascade_output_change_fraction fann_get_cascade_output_stagnation_epochs fann_get_cascade_weight_multiplier fann_get_connection_array  contained
syn keyword phpFunctions  fann_get_connection_rate fann_get_errno fann_get_errstr fann_get_layer_array fann_get_learning_momentum fann_get_learning_rate fann_get_MSE fann_get_network_type fann_get_num_input fann_get_num_layers fann_get_num_output fann_get_quickprop_decay fann_get_quickprop_mu fann_get_rprop_decrease_factor fann_get_rprop_delta_max fann_get_rprop_delta_min fann_get_rprop_delta_zero fann_get_rprop_increase_factor fann_get_sarprop_step_error_shift fann_get_sarprop_step_error_threshold_factor  contained
syn keyword phpFunctions  fann_get_sarprop_temperature fann_get_sarprop_weight_decay_shift fann_get_total_connections fann_get_total_neurons fann_get_train_error_function fann_get_training_algorithm fann_get_train_stop_function fann_init_weights fann_length_train_data fann_merge_train_data fann_num_input_train_data fann_num_output_train_data fann_print_error fann_randomize_weights fann_read_train_from_file fann_reset_errno fann_reset_errstr fann_reset_MSE fann_run fann_save  contained
syn keyword phpFunctions  fann_save_train fann_scale_input fann_scale_input_train_data fann_scale_output fann_scale_output_train_data fann_scale_train fann_scale_train_data fann_set_activation_function fann_set_activation_function_hidden fann_set_activation_function_layer fann_set_activation_function_output fann_set_activation_steepness fann_set_activation_steepness_hidden fann_set_activation_steepness_layer fann_set_activation_steepness_output fann_set_bit_fail_limit fann_set_callback fann_set_cascade_activation_functions fann_set_cascade_activation_steepnesses fann_set_cascade_candidate_change_fraction  contained
syn keyword phpFunctions  fann_set_cascade_candidate_limit fann_set_cascade_candidate_stagnation_epochs fann_set_cascade_max_cand_epochs fann_set_cascade_max_out_epochs fann_set_cascade_min_cand_epochs fann_set_cascade_min_out_epochs fann_set_cascade_num_candidate_groups fann_set_cascade_output_change_fraction fann_set_cascade_output_stagnation_epochs fann_set_cascade_weight_multiplier fann_set_error_log fann_set_input_scaling_params fann_set_learning_momentum fann_set_learning_rate fann_set_output_scaling_params fann_set_quickprop_decay fann_set_quickprop_mu fann_set_rprop_decrease_factor fann_set_rprop_delta_max fann_set_rprop_delta_min  contained
syn keyword phpFunctions  fann_set_rprop_delta_zero fann_set_rprop_increase_factor fann_set_sarprop_step_error_shift fann_set_sarprop_step_error_threshold_factor fann_set_sarprop_temperature fann_set_sarprop_weight_decay_shift fann_set_scaling_params fann_set_train_error_function fann_set_training_algorithm fann_set_train_stop_function fann_set_weight fann_set_weight_array fann_shuffle_train_data fann_subset_train_data fann_test fann_test_data fann_train fann_train_epoch fann_train_on_data fann_train_on_file  contained
syn keyword phpFunctions  fastcgi_finish_request fbsql_affected_rows fbsql_autocommit fbsql_blob_size fbsql_change_user fbsql_clob_size fbsql_close fbsql_commit fbsql_connect fbsql_create_blob fbsql_create_clob fbsql_create_db fbsql_database fbsql_database_password fbsql_data_seek fbsql_db_query fbsql_db_status fbsql_drop_db fbsql_errno fbsql_error  contained
syn keyword phpFunctions  fbsql_fetch_array fbsql_fetch_assoc fbsql_fetch_field fbsql_fetch_lengths fbsql_fetch_object fbsql_fetch_row fbsql_field_flags fbsql_field_len fbsql_field_name fbsql_field_seek fbsql_field_table fbsql_field_type fbsql_free_result fbsql_get_autostart_info fbsql_hostname fbsql_insert_id fbsql_list_dbs fbsql_list_fields fbsql_list_tables fbsql_next_result  contained
syn keyword phpFunctions  fbsql_num_fields fbsql_num_rows fbsql_password fbsql_pconnect fbsql_query fbsql_read_blob fbsql_read_clob fbsql_result fbsql_rollback fbsql_rows_fetched fbsql_select_db fbsql_set_characterset fbsql_set_lob_mode fbsql_set_password fbsql_set_transaction fbsql_start_db fbsql_stop_db fbsql_table_name fbsql_username fbsql_warnings  contained
syn keyword phpFunctions  fclose fdf_add_doc_javascript fdf_add_template fdf_close fdf_create fdf_enum_values fdf_errno fdf_error fdf_get_ap fdf_get_attachment fdf_get_encoding fdf_get_file fdf_get_flags fdf_get_opt fdf_get_status fdf_get_value fdf_get_version fdf_header fdf_next_field_name fdf_open  contained
syn keyword phpFunctions  fdf_open_string fdf_remove_item fdf_save fdf_save_string fdf_set_ap fdf_set_encoding fdf_set_file fdf_set_flags fdf_set_javascript_action fdf_set_on_import_javascript fdf_set_opt fdf_set_status fdf_set_submit_form_action fdf_set_target_frame fdf_set_value fdf_set_version feof fflush fgetc fgetcsv  contained
syn keyword phpFunctions  fgets fgetss file fileatime filectime file_exists file_get_contents filegroup fileinode filemtime fileowner fileperms filepro filepro_fieldcount filepro_fieldname filepro_fieldtype filepro_fieldwidth filepro_retrieve filepro_rowcount file_put_contents  contained
syn keyword phpFunctions  filesize filetype filter filter_has_var filter_id filter_input filter_input_array filter_list filter_var filter_var_array finfo_close finfo_open floatval flock floor flush fmod fnmatch fopen forward_static_call  contained
syn keyword phpFunctions  forward_static_call_array fpassthru fprintf fputcsv fread frenchtojd fribidi_log2vis fscanf fseek fsockopen fstat ftell ftok ftp_alloc ftp_cdup ftp_chdir ftp_chmod ftp_close ftp_connect ftp_delete  contained
syn keyword phpFunctions  ftp_exec ftp_fget ftp_fput ftp_get ftp_get_option ftp_login ftp_mdtm ftp_mkdir ftp_nb_continue ftp_nb_fget ftp_nb_fput ftp_nb_get ftp_nb_put ftp_nlist ftp_pasv ftp_put ftp_pwd ftp_raw ftp_rawlist ftp_rename  contained
syn keyword phpFunctions  ftp_rmdir ftp_set_option ftp_site ftp_size ftp_ssl_connect ftp_systype ftruncate func_get_arg func_get_args func_num_args function_exists fwrite gc_collect_cycles gc_disable gc_enable gc_enabled gc_mem_caches gd_info GearmanWorker geoip_asnum_by_name  contained
syn keyword phpFunctions  geoip_continent_code_by_name geoip_country_code3_by_name geoip_country_code_by_name geoip_country_name_by_name geoip_database_info geoip_db_avail geoip_db_filename geoip_db_get_all_info geoip_domain_by_name geoip_id_by_name geoip_isp_by_name geoip_netspeedcell_by_name geoip_org_by_name geoip_record_by_name geoip_region_by_name geoip_region_name_by_code geoip_setup_custom_directory geoip_time_zone_by_country_and_region get getallheaders  contained
syn keyword phpFunctions  get_browser get_called_class getcell getcellbynum get_cfg_var get_class get_class_methods get_class_vars getcommadelimited get_current_user getcwd getdate get_declared_classes get_declared_interfaces get_declared_traits get_defined_constants get_defined_functions get_defined_vars getenv get_extension_funcs  contained
syn keyword phpFunctions  getheader get_headers gethostbyaddr gethostbyname gethostbynamel gethostname get_html_translation_table getimagesize getimagesizefromstring get_included_files get_include_path getlastmod get_loaded_extensions get_magic_quotes_gpc get_magic_quotes_runtime get_meta_tags getmxrr getmygid getmyinode getmypid  contained
syn keyword phpFunctions  getmyuid get_object_vars getopt get_parent_class getprotobyname getprotobynumber getrandmax get_resources get_resource_type getrusage getservbyname getservbyport gettext gettimeofday gettype glob gmdate gmmktime gmp_abs gmp_add  contained
syn keyword phpFunctions  gmp_and gmp_clrbit gmp_cmp gmp_com gmp_divexact gmp_div_q gmp_div_qr gmp_div_r gmp_export gmp_fact gmp_gcd gmp_gcdext gmp_hamdist gmp_import gmp_init gmp_intval gmp_invert gmp_jacobi gmp_legendre gmp_mod  contained
syn keyword phpFunctions  gmp_mul gmp_neg gmp_nextprime gmp_or gmp_perfect_square gmp_popcount gmp_pow gmp_powm gmp_prob_prime gmp_random gmp_random_bits gmp_random_range gmp_random_seed gmp_root gmp_rootrem gmp_scan0 gmp_scan1 gmp_setbit gmp_sign gmp_sqrt  contained
syn keyword phpFunctions  gmp_sqrtrem gmp_strval gmp_sub gmp_testbit gmp_xor gmstrftime gnupg_adddecryptkey gnupg_addencryptkey gnupg_addsignkey gnupg_cleardecryptkeys gnupg_clearencryptkeys gnupg_clearsignkeys gnupg_decrypt gnupg_decryptverify gnupg_encrypt gnupg_encryptsign gnupg_export gnupg_geterror gnupg_getprotocol gnupg_import  contained
syn keyword phpFunctions  gnupg_init gnupg_keyinfo gnupg_setarmor gnupg_seterrormode gnupg_setsignmode gnupg_sign gnupg_verify gopher_parsedir grapheme_extract grapheme_stripos grapheme_stristr grapheme_strlen grapheme_strpos grapheme_strripos grapheme_strrpos grapheme_strstr grapheme_substr gregoriantojd gupnp_context_get_host_ip gupnp_context_get_port  contained
syn keyword phpFunctions  gupnp_context_get_subscription_timeout gupnp_context_host_path gupnp_context_new gupnp_context_set_subscription_timeout gupnp_context_timeout_add gupnp_context_unhost_path gupnp_control_point_browse_start gupnp_control_point_browse_stop gupnp_control_point_callback_set gupnp_control_point_new gupnp_device_action_callback_set gupnp_device_info_get gupnp_device_info_get_service gupnp_root_device_get_available gupnp_root_device_get_relative_location gupnp_root_device_new gupnp_root_device_set_available gupnp_root_device_start gupnp_root_device_stop gupnp_service_action_get  contained
syn keyword phpFunctions  gupnp_service_action_return gupnp_service_action_return_error gupnp_service_action_set gupnp_service_freeze_notify gupnp_service_info_get gupnp_service_info_get_introspection gupnp_service_introspection_get_state_variable gupnp_service_notify gupnp_service_proxy_action_get gupnp_service_proxy_action_set gupnp_service_proxy_add_notify gupnp_service_proxy_callback_set gupnp_service_proxy_get_subscribed gupnp_service_proxy_remove_notify gupnp_service_proxy_send_action gupnp_service_proxy_set_subscribed gupnp_service_thaw_notify gzclose gzcompress gzdecode  contained
syn keyword phpFunctions  gzdeflate gzencode gzeof gzfile gzgetc gzgets gzgetss gzinflate gzopen gzpassthru gzread gzrewind gzseek gztell gzuncompress gzwrite halt_compiler hash hash_algos hash_copy  contained
syn keyword phpFunctions  hash_equals hash_file hash_final hash_hmac hash_hmac_file hash_init hash_pbkdf2 hash_update hash_update_file hash_update_stream header header_register_callback header_remove headers_list headers_sent hebrev hebrevc hex2bin hexdec highlight_file  contained
syn keyword phpFunctions  highlight_string htmlentities html_entity_decode htmlspecialchars htmlspecialchars_decode http_build_cookie http_build_query http_build_str http_build_url http_cache_etag http_cache_last_modified http_chunked_decode http_date http_deflate http_get http_get_request_body http_get_request_body_stream http_get_request_headers http_head http_inflate  contained
syn keyword phpFunctions  http_match_etag http_match_modified http_match_request_header http_negotiate_charset http_negotiate_content_type http_negotiate_language http_parse_cookie http_parse_headers http_parse_message http_parse_params http_persistent_handles_clean http_persistent_handles_count http_persistent_handles_ident http_post_data http_post_fields http_put_data http_put_file http_put_stream http_redirect http_request  contained
syn keyword phpFunctions  http_request_body_encode http_request_method_exists http_request_method_name http_request_method_register http_request_method_unregister http_response_code http_send_content_disposition http_send_content_type http_send_data http_send_file http_send_last_modified http_send_status http_send_stream http_support http_throttle hwapi_attribute_new hwapi_content_new hwapi_hgcsp hwapi_object_new hypot  contained
syn keyword phpFunctions  ibase_add_user ibase_affected_rows ibase_backup ibase_blob_add ibase_blob_cancel ibase_blob_close ibase_blob_create ibase_blob_echo ibase_blob_get ibase_blob_import ibase_blob_info ibase_blob_open ibase_close ibase_commit ibase_commit_ret ibase_connect ibase_db_info ibase_delete_user ibase_drop_db ibase_errcode  contained
syn keyword phpFunctions  ibase_errmsg ibase_execute ibase_fetch_assoc ibase_fetch_object ibase_fetch_row ibase_field_info ibase_free_event_handler ibase_free_query ibase_free_result ibase_gen_id ibase_maintain_db ibase_modify_user ibase_name_result ibase_num_fields ibase_num_params ibase_param_info ibase_pconnect ibase_prepare ibase_query ibase_restore  contained
syn keyword phpFunctions  ibase_rollback ibase_rollback_ret ibase_server_info ibase_service_attach ibase_service_detach ibase_set_event_handler ibase_trans ibase_wait_event iconv iconv_get_encoding iconv_mime_decode iconv_mime_decode_headers iconv_mime_encode iconv_set_encoding iconv_strlen iconv_strpos iconv_strrpos iconv_substr id3_get_frame_long_name id3_get_frame_short_name  contained
syn keyword phpFunctions  id3_get_genre_id id3_get_genre_list id3_get_genre_name id3_get_tag id3_get_version id3_remove_tag id3_set_tag idate idn_to_ascii idn_to_utf8 ifx_affected_rows ifx_blobinfile_mode ifx_byteasvarchar ifx_close ifx_connect ifx_copy_blob ifx_create_blob ifx_create_char ifx_do ifx_error  contained
syn keyword phpFunctions  ifx_errormsg ifx_fetch_row ifx_fieldproperties ifx_fieldtypes ifx_free_blob ifx_free_char ifx_free_result ifx_get_blob ifx_get_char ifx_getsqlca ifx_htmltbl_result ifx_nullformat ifx_num_fields ifx_num_rows ifx_pconnect ifx_prepare ifx_query ifx_textasvarchar ifx_update_blob ifx_update_char  contained
syn keyword phpFunctions  ifxus_close_slob ifxus_create_slob ifxus_free_slob ifxus_open_slob ifxus_read_slob ifxus_seek_slob ifxus_tell_slob ifxus_write_slob ignore_user_abort iis_add_server iis_get_dir_security iis_get_script_map iis_get_server_by_comment iis_get_server_by_path iis_get_server_rights iis_get_service_state iis_remove_server iis_set_app_settings iis_set_dir_security iis_set_script_map  contained
syn keyword phpFunctions  iis_set_server_rights iis_start_server iis_start_service iis_stop_server iis_stop_service image2wbmp imageaffine imageaffinematrixconcat imageaffinematrixget imagealphablending imageantialias imagearc imagechar imagecharup imagecolorallocate imagecolorallocatealpha imagecolorat imagecolorclosest imagecolorclosestalpha imagecolorclosesthwb  contained
syn keyword phpFunctions  imagecolordeallocate imagecolorexact imagecolorexactalpha imagecolormatch imagecolorresolve imagecolorresolvealpha imagecolorset imagecolorsforindex imagecolorstotal imagecolortransparent imageconvolution imagecopy imagecopymerge imagecopymergegray imagecopyresampled imagecopyresized imagecreate imagecreatefromgd imagecreatefromgd2 imagecreatefromgd2part  contained
syn keyword phpFunctions  imagecreatefromgif imagecreatefromjpeg imagecreatefrompng imagecreatefromstring imagecreatefromwbmp imagecreatefromwebp imagecreatefromxbm imagecreatefromxpm imagecreatetruecolor imagecrop imagecropauto imagedashedline imagedestroy imageellipse imagefill imagefilledarc imagefilledellipse imagefilledpolygon imagefilledrectangle imagefilltoborder  contained
syn keyword phpFunctions  imagefilter imageflip imagefontheight imagefontwidth imageftbbox imagefttext imagegammacorrect imagegd imagegd2 imagegif imagegrabscreen imagegrabwindow imageinterlace imageistruecolor imagejpeg imagelayereffect imageline imageloadfont imagepalettecopy imagepalettetotruecolor  contained
syn keyword phpFunctions  imagepng imagepolygon imagepsbbox imagepsencodefont imagepsextendfont imagepsfreefont imagepsloadfont imagepsslantfont imagepstext imagerectangle imagerotate imagesavealpha imagescale imagesetbrush imagesetinterpolation imagesetpixel imagesetstyle imagesetthickness imagesettile imagestring  contained
syn keyword phpFunctions  imagestringup imagesx imagesy imagetruecolortopalette imagettfbbox imagettftext imagetypes image_type_to_extension image_type_to_mime_type imagewbmp imagewebp imagexbm imap_8bit imap_alerts imap_append imap_base64 imap_binary imap_body imap_bodystruct imap_check  contained
syn keyword phpFunctions  imap_clearflag_full imap_close imap_createmailbox imap_delete imap_deletemailbox imap_errors imap_expunge imap_fetchbody imap_fetchheader imap_fetchmime imap_fetch_overview imap_fetchstructure imap_gc imap_getacl imap_getmailboxes imap_get_quota imap_get_quotaroot imap_getsubscribed imap_headerinfo imap_headers  contained
syn keyword phpFunctions  imap_last_error imap_list imap_listscan imap_lsub imap_mail imap_mailboxmsginfo imap_mail_compose imap_mail_copy imap_mail_move imap_mime_header_decode imap_msgno imap_num_msg imap_num_recent imap_open imap_ping imap_qprint imap_renamemailbox imap_reopen imap_rfc822_parse_adrlist imap_rfc822_parse_headers  contained
syn keyword phpFunctions  imap_rfc822_write_address imap_savebody imap_search imap_setacl imap_setflag_full imap_set_quota imap_sort imap_status imap_subscribe imap_thread imap_timeout imap_uid imap_undelete imap_unsubscribe imap_utf7_decode imap_utf7_encode imap_utf8 implode import_request_variables in_array  contained
syn keyword phpFunctions  inclued_get_data inet_ntop inet_pton ingres_autocommit ingres_autocommit_state ingres_charset ingres_close ingres_commit ingres_connect ingres_cursor ingres_errno ingres_error ingres_errsqlstate ingres_escape_string ingres_execute ingres_fetch_array ingres_fetch_assoc ingres_fetch_object ingres_fetch_proc_return ingres_fetch_row  contained
syn keyword phpFunctions  ingres_field_length ingres_field_name ingres_field_nullable ingres_field_precision ingres_field_scale ingres_field_type ingres_free_result ingres_next_error ingres_num_fields ingres_num_rows ingres_pconnect ingres_prepare ingres_query ingres_result_seek ingres_rollback ingres_set_environment ingres_unbuffered_query ini_get ini_get_all ini_restore  contained
syn keyword phpFunctions  ini_set initconn initengine inotify_add_watch inotify_init inotify_queue_len inotify_read inotify_rm_watch intdiv interface_exists intlcal_add intlcal_after intlcal_before intlcal_clear intlcal_create_instance intlcal_equals intlcal_field_difference intlcal_from_date_time intlcal_get intlcal_get_actual_maximum  contained
syn keyword phpFunctions  intlcal_get_actual_minimum intlcal_get_available_locales intlcal_get_day_of_week_type intlcal_get_error_code intlcal_get_error_message intlcal_get_first_day_of_week intlcal_get_greatest_minimum intlcal_get_keyword_values_for_locale intlcal_get_least_maximum intlcal_get_locale intlcal_get_maximum intlcal_get_minimal_days_in_first_week intlcal_get_minimum intlcal_get_now intlcal_get_repeated_wall_time_option intlcal_get_skipped_wall_time_option intlcal_get_time intlcal_get_time_zone intlcal_get_type intlcal_get_weekend_transition  contained
syn keyword phpFunctions  intlcal_in_daylight_time intlcal_is_equivalent_to intlcal_is_lenient intlcal_is_set intlcal_is_weekend intlcal_roll intlcal_set intlcal_set_first_day_of_week intlcal_set_lenient intlcal_set_repeated_wall_time_option intlcal_set_skipped_wall_time_option intlcal_set_time intlcal_set_time_zone intlcal_to_date_time intl_error_name intl_get_error_code intl_get_error_message intl_is_failure intltz_get_error_code intltz_get_error_message  contained
syn keyword phpFunctions  intval invoke ip2long iptcembed iptcparse is_a is_array is_bool is_callable iscommadelimited is_dir is_executable is_file is_finite is_float is_infinite is_int is_link is_nan is_null  contained
syn keyword phpFunctions  is_numeric is_object is_readable is_resource is_scalar isset is_soap_fault is_string is_subclass_of is_tainted is_uploaded_file is_writable iterator_apply iterator_count iterator_to_array jddayofweek jdmonthname jdtofrench jdtogregorian jdtojewish  contained
syn keyword phpFunctions  jdtojulian jdtounix jewishtojd jpeg2wbmp json_decode json_encode json_last_error json_last_error_msg judy_type judy_version juliantojd kadm5_chpass_principal kadm5_create_principal kadm5_delete_principal kadm5_destroy kadm5_flush kadm5_get_policies kadm5_get_principal kadm5_get_principals kadm5_init_with_password  contained
syn keyword phpFunctions  kadm5_modify_principal key krsort ksort lcfirst lcg_value lchgrp lchown ldap_8859_to_t61 ldap_add ldap_bind ldap_compare ldap_connect ldap_control_paged_result ldap_control_paged_result_response ldap_count_entries ldap_delete ldap_dn2ufn ldap_err2str ldap_errno  contained
syn keyword phpFunctions  ldap_error ldap_escape ldap_explode_dn ldap_first_attribute ldap_first_entry ldap_first_reference ldap_free_result ldap_get_attributes ldap_get_dn ldap_get_entries ldap_get_option ldap_get_values ldap_get_values_len ldap_list ldap_mod_add ldap_mod_del ldap_modify ldap_modify_batch ldap_mod_replace ldap_next_attribute  contained
syn keyword phpFunctions  ldap_next_entry ldap_next_reference ldap_parse_reference ldap_parse_result ldap_read ldap_rename ldap_sasl_bind ldap_search ldap_set_option ldap_set_rebind_proc ldap_sort ldap_start_tls ldap_t61_to_8859 ldap_unbind levenshtein libxml_clear_errors libxml_disable_entity_loader libxml_get_errors libxml_get_last_error libxml_set_external_entity_loader  contained
syn keyword phpFunctions  libxml_set_streams_context libxml_use_internal_errors link linkinfo list locale_accept_from_http locale_compose localeconv locale_filter_matches locale_get_all_variants locale_get_default locale_get_display_language locale_get_display_name locale_get_display_region locale_get_display_script locale_get_display_variant locale_get_keywords locale_get_primary_language locale_get_region locale_get_script  contained
syn keyword phpFunctions  locale_lookup locale_parse locale_set_default localtime log log10 log1p log_cmd_delete log_cmd_insert log_cmd_update log_getmore log_killcursor log_reply log_write_batch long2ip lstat ltrim lzf_compress lzf_decompress lzf_optimized_for  contained
syn keyword phpFunctions  mail mailparse_determine_best_xfer_encoding mailparse_msg_create mailparse_msg_extract_part mailparse_msg_extract_part_file mailparse_msg_extract_whole_part_file mailparse_msg_free mailparse_msg_get_part mailparse_msg_get_part_data mailparse_msg_get_structure mailparse_msg_parse mailparse_msg_parse_file mailparse_rfc822_parse_addresses mailparse_stream_encode mailparse_uudecode_all max maxconntimeout maxdb_affected_rows maxdb_autocommit maxdb_change_user  contained
syn keyword phpFunctions  maxdb_character_set_name maxdb_close maxdb_commit maxdb_connect maxdb_connect_errno maxdb_connect_error maxdb_data_seek maxdb_debug maxdb_disable_reads_from_master maxdb_disable_rpl_parse maxdb_dump_debug_info maxdb_embedded_connect maxdb_enable_reads_from_master maxdb_enable_rpl_parse maxdb_errno maxdb_error maxdb_fetch_array maxdb_fetch_assoc maxdb_fetch_field maxdb_fetch_field_direct  contained
syn keyword phpFunctions  maxdb_fetch_fields maxdb_fetch_lengths maxdb_fetch_object maxdb_fetch_row maxdb_field_count maxdb_field_seek maxdb_field_tell maxdb_free_result maxdb_get_client_info maxdb_get_client_version maxdb_get_host_info maxdb_get_proto_info maxdb_get_server_info maxdb_get_server_version maxdb_info maxdb_init maxdb_insert_id maxdb_kill maxdb_master_query maxdb_more_results  contained
syn keyword phpFunctions  maxdb_multi_query maxdb_next_result maxdb_num_fields maxdb_num_rows maxdb_options maxdb_ping maxdb_prepare maxdb_query maxdb_real_connect maxdb_real_escape_string maxdb_real_query maxdb_report maxdb_rollback maxdb_rpl_parse_enabled maxdb_rpl_probe maxdb_rpl_query_type maxdb_select_db maxdb_send_query maxdb_server_end maxdb_server_init  contained
syn keyword phpFunctions  maxdb_sqlstate maxdb_ssl_set maxdb_stat maxdb_stmt_affected_rows maxdb_stmt_bind_param maxdb_stmt_bind_result maxdb_stmt_close maxdb_stmt_close_long_data maxdb_stmt_data_seek maxdb_stmt_errno maxdb_stmt_error maxdb_stmt_execute maxdb_stmt_fetch maxdb_stmt_free_result maxdb_stmt_init maxdb_stmt_num_rows maxdb_stmt_param_count maxdb_stmt_prepare maxdb_stmt_reset maxdb_stmt_result_metadata  contained
syn keyword phpFunctions  maxdb_stmt_send_long_data maxdb_stmt_sqlstate maxdb_stmt_store_result maxdb_store_result maxdb_thread_id maxdb_thread_safe maxdb_use_result maxdb_warning_count mb_check_encoding mb_convert_case mb_convert_encoding mb_convert_kana mb_convert_variables mb_decode_mimeheader mb_decode_numericentity mb_detect_encoding mb_detect_order mb_encode_mimeheader mb_encode_numericentity mb_encoding_aliases  contained
syn keyword phpFunctions  mb_ereg mb_eregi mb_eregi_replace mb_ereg_match mb_ereg_replace mb_ereg_replace_callback mb_ereg_search mb_ereg_search_getpos mb_ereg_search_getregs mb_ereg_search_init mb_ereg_search_pos mb_ereg_search_regs mb_ereg_search_setpos mb_get_info mb_http_input mb_http_output mb_internal_encoding mb_language mb_list_encodings mb_output_handler  contained
syn keyword phpFunctions  mb_parse_str mb_preferred_mime_name mb_regex_encoding mb_regex_set_options mb_send_mail mb_split mb_strcut mb_strimwidth mb_stripos mb_stristr mb_strlen mb_strpos mb_strrchr mb_strrichr mb_strripos mb_strrpos mb_strstr mb_strtolower mb_strtoupper mb_strwidth  contained
syn keyword phpFunctions  mb_substitute_character mb_substr mb_substr_count mcrypt_cbc mcrypt_cfb mcrypt_create_iv mcrypt_decrypt mcrypt_ecb mcrypt_enc_get_algorithms_name mcrypt_enc_get_block_size mcrypt_enc_get_iv_size mcrypt_enc_get_key_size mcrypt_enc_get_modes_name mcrypt_enc_get_supported_key_sizes mcrypt_enc_is_block_algorithm mcrypt_enc_is_block_algorithm_mode mcrypt_enc_is_block_mode mcrypt_encrypt mcrypt_enc_self_test mcrypt_generic  contained
syn keyword phpFunctions  mcrypt_generic_deinit mcrypt_generic_end mcrypt_generic_init mcrypt_get_block_size mcrypt_get_cipher_name mcrypt_get_iv_size mcrypt_get_key_size mcrypt_list_algorithms mcrypt_list_modes mcrypt_module_close mcrypt_module_get_algo_block_size mcrypt_module_get_algo_key_size mcrypt_module_get_supported_key_sizes mcrypt_module_is_block_algorithm mcrypt_module_is_block_algorithm_mode mcrypt_module_is_block_mode mcrypt_module_open mcrypt_module_self_test mcrypt_ofb md5  contained
syn keyword phpFunctions  md5_file mdecrypt_generic memcache_debug memory_get_peak_usage memory_get_usage metaphone method_exists mhash mhash_count mhash_get_block_size mhash_get_hash_name mhash_keygen_s2k microtime mime_content_type min ming_keypress ming_setcubicthreshold ming_setscale ming_setswfcompression ming_useconstants  contained
syn keyword phpFunctions  ming_useswfversion mkdir mktime money_format MongoDB monitor move_uploaded_file mqseries_back mqseries_begin mqseries_close mqseries_cmit mqseries_conn mqseries_connx mqseries_disc mqseries_get mqseries_inq mqseries_open mqseries_put mqseries_put1 mqseries_set  contained
syn keyword phpFunctions  mqseries_strerror msession_connect msession_count msession_create msession_destroy msession_disconnect msession_find msession_get msession_get_array msession_get_data msession_inc msession_list msession_listvar msession_lock msession_plugin msession_randstr msession_set msession_set_array msession_set_data msession_timeout  contained
syn keyword phpFunctions  msession_uniq msession_unlock msgfmt_create msgfmt_format msgfmt_format_message msgfmt_get_error_code msgfmt_get_error_message msgfmt_get_locale msgfmt_get_pattern msgfmt_parse msgfmt_parse_message msgfmt_set_pattern msg_get_queue msg_queue_exists msg_receive msg_remove_queue msg_send msg_set_queue msg_stat_queue msql_affected_rows  contained
syn keyword phpFunctions  msql_close msql_connect msql_create_db msql_data_seek msql_db_query msql_drop_db msql_error msql_fetch_array msql_fetch_field msql_fetch_object msql_fetch_row msql_field_flags msql_field_len msql_field_name msql_field_seek msql_field_table msql_field_type msql_free_result msql_list_dbs msql_list_fields  contained
syn keyword phpFunctions  msql_list_tables msql_num_fields msql_num_rows msql_pconnect msql_query msql_result msql_select_db mssql_bind mssql_close mssql_connect mssql_data_seek mssql_execute mssql_fetch_array mssql_fetch_assoc mssql_fetch_batch mssql_fetch_field mssql_fetch_object mssql_fetch_row mssql_field_length mssql_field_name  contained
syn keyword phpFunctions  mssql_field_seek mssql_field_type mssql_free_result mssql_free_statement mssql_get_last_message mssql_guid_string mssql_init mssql_min_error_severity mssql_min_message_severity mssql_next_result mssql_num_fields mssql_num_rows mssql_pconnect mssql_query mssql_result mssql_rows_affected mssql_select_db mt_getrandmax mt_rand mt_srand  contained
syn keyword phpFunctions  mysql_affected_rows mysql_client_encoding mysql_close mysql_connect mysql_create_db mysql_data_seek mysql_db_name mysql_db_query mysql_drop_db mysql_errno mysql_error mysql_escape_string mysql_fetch_array mysql_fetch_assoc mysql_fetch_field mysql_fetch_lengths mysql_fetch_object mysql_fetch_row mysql_field_flags mysql_field_len  contained
syn keyword phpFunctions  mysql_field_name mysql_field_seek mysql_field_table mysql_field_type mysql_free_result mysql_get_client_info mysql_get_host_info mysql_get_proto_info mysql_get_server_info $mysqli mysqli_affected_rows mysqli_autocommit mysqli_begin_transaction mysqli_change_user mysqli_character_set_name mysqli_close mysqli_commit mysqli_connect_errno mysqli_connect_error mysqli_data_seek  contained
syn keyword phpFunctions  mysqli_debug mysqli_disable_reads_from_master mysqli_disable_rpl_parse mysqli_dump_debug_info mysqli_embedded_server_end mysqli_embedded_server_start mysqli_enable_reads_from_master mysqli_enable_rpl_parse mysqli_errno mysqli_error mysqli_error_list mysqli_fetch_all mysqli_fetch_array mysqli_fetch_assoc mysqli_fetch_field mysqli_fetch_field_direct mysqli_fetch_fields mysqli_fetch_lengths mysqli_fetch_object mysqli_fetch_row  contained
syn keyword phpFunctions  mysqli_field_count mysqli_field_seek mysqli_field_tell mysqli_free_result mysqli_get_cache_stats mysqli_get_charset mysqli_get_client_info mysqli_get_client_stats mysqli_get_client_version mysqli_get_connection_stats mysqli_get_host_info mysqli_get_links_stats mysqli_get_proto_info mysqli_get_server_info mysqli_get_server_version mysqli_get_warnings mysqli_info mysqli_init mysqli_insert_id mysqli_kill  contained
syn keyword phpFunctions  mysqli_master_query mysqli_more_results mysqli_multi_query mysqli_next_result mysql_info mysql_insert_id mysqli_num_fields mysqli_num_rows mysqli_options mysqli_ping mysqli_poll mysqli_prepare mysqli_query mysqli_real_connect mysqli_real_escape_string mysqli_real_query mysqli_reap_async_query mysqli_refresh mysqli_release_savepoint mysqli_rollback  contained
syn keyword phpFunctions  mysqli_rpl_parse_enabled mysqli_rpl_probe mysqli_rpl_query_type mysqli_savepoint mysqli_select_db mysqli_send_query mysqli_set_charset mysqli_set_local_infile_default mysqli_set_local_infile_handler mysqli_slave_query mysqli_sqlstate mysqli_ssl_set mysqli_stat mysqli_stmt_affected_rows mysqli_stmt_attr_get mysqli_stmt_attr_set mysqli_stmt_bind_param mysqli_stmt_bind_result mysqli_stmt_close mysqli_stmt_data_seek  contained
syn keyword phpFunctions  mysqli_stmt_errno mysqli_stmt_error mysqli_stmt_error_list mysqli_stmt_execute mysqli_stmt_fetch mysqli_stmt_field_count mysqli_stmt_free_result mysqli_stmt_get_result mysqli_stmt_get_warnings mysqli_stmt_init mysqli_stmt_insert_id mysqli_stmt_more_results mysqli_stmt_next_result mysqli_stmt_num_rows mysqli_stmt_param_count mysqli_stmt_prepare mysqli_stmt_reset mysqli_stmt_result_metadata mysqli_stmt_send_long_data mysqli_stmt_sqlstate  contained
syn keyword phpFunctions  mysqli_stmt_store_result mysqli_store_result mysqli_thread_id mysqli_thread_safe mysqli_use_result mysqli_warning_count mysql_list_dbs mysql_list_fields mysql_list_processes mysql_list_tables mysqlnd_memcache_get_config mysqlnd_memcache_set mysqlnd_ms_dump_servers mysqlnd_ms_fabric_select_global mysqlnd_ms_fabric_select_shard mysqlnd_ms_get_last_gtid mysqlnd_ms_get_last_used_connection mysqlnd_ms_get_stats mysqlnd_ms_match_wild mysqlnd_ms_query_is_select  contained
syn keyword phpFunctions  mysqlnd_ms_set_qos mysqlnd_ms_set_user_pick_server mysqlnd_ms_xa_begin mysqlnd_ms_xa_commit mysqlnd_ms_xa_gc mysqlnd_ms_xa_rollback mysqlnd_qc_clear_cache mysqlnd_qc_get_available_handlers mysqlnd_qc_get_cache_info mysqlnd_qc_get_core_stats mysqlnd_qc_get_normalized_query_trace_log mysqlnd_qc_get_query_trace_log mysqlnd_qc_set_cache_condition mysqlnd_qc_set_is_select mysqlnd_qc_set_storage_handler mysqlnd_qc_set_user_handlers mysqlnd_uh_convert_to_mysqlnd mysqlnd_uh_set_connection_proxy mysqlnd_uh_set_statement_proxy mysql_num_fields  contained
syn keyword phpFunctions  mysql_num_rows mysql_pconnect mysql_ping mysql_query mysql_real_escape_string mysql_result mysql_select_db mysql_set_charset mysql_stat mysql_tablename mysql_thread_id mysql_unbuffered_query natcasesort natsort ncurses_addch ncurses_addchnstr ncurses_addchstr ncurses_addnstr ncurses_addstr ncurses_assume_default_colors  contained
syn keyword phpFunctions  ncurses_attroff ncurses_attron ncurses_attrset ncurses_baudrate ncurses_beep ncurses_bkgd ncurses_bkgdset ncurses_border ncurses_bottom_panel ncurses_can_change_color ncurses_cbreak ncurses_clear ncurses_clrtobot ncurses_clrtoeol ncurses_color_content ncurses_color_set ncurses_curs_set ncurses_define_key ncurses_def_prog_mode ncurses_def_shell_mode  contained
syn keyword phpFunctions  ncurses_delay_output ncurses_delch ncurses_deleteln ncurses_del_panel ncurses_delwin ncurses_doupdate ncurses_echo ncurses_echochar ncurses_end ncurses_erase ncurses_erasechar ncurses_filter ncurses_flash ncurses_flushinp ncurses_getch ncurses_getmaxyx ncurses_getmouse ncurses_getyx ncurses_halfdelay ncurses_has_colors  contained
syn keyword phpFunctions  ncurses_has_ic ncurses_has_il ncurses_has_key ncurses_hide_panel ncurses_hline ncurses_inch ncurses_init ncurses_init_color ncurses_init_pair ncurses_insch ncurses_insdelln ncurses_insertln ncurses_insstr ncurses_instr ncurses_isendwin ncurses_keyok ncurses_keypad ncurses_killchar ncurses_longname ncurses_meta  contained
syn keyword phpFunctions  ncurses_mouseinterval ncurses_mousemask ncurses_mouse_trafo ncurses_move ncurses_move_panel ncurses_mvaddch ncurses_mvaddchnstr ncurses_mvaddchstr ncurses_mvaddnstr ncurses_mvaddstr ncurses_mvcur ncurses_mvdelch ncurses_mvgetch ncurses_mvhline ncurses_mvinch ncurses_mvvline ncurses_mvwaddstr ncurses_napms ncurses_newpad ncurses_new_panel  contained
syn keyword phpFunctions  ncurses_newwin ncurses_nl ncurses_nocbreak ncurses_noecho ncurses_nonl ncurses_noqiflush ncurses_noraw ncurses_pair_content ncurses_panel_above ncurses_panel_below ncurses_panel_window ncurses_pnoutrefresh ncurses_prefresh ncurses_putp ncurses_qiflush ncurses_raw ncurses_refresh ncurses_replace_panel ncurses_reset_prog_mode ncurses_reset_shell_mode  contained
syn keyword phpFunctions  ncurses_resetty ncurses_savetty ncurses_scr_dump ncurses_scr_init ncurses_scrl ncurses_scr_restore ncurses_scr_set ncurses_show_panel ncurses_slk_attr ncurses_slk_attroff ncurses_slk_attron ncurses_slk_attrset ncurses_slk_clear ncurses_slk_color ncurses_slk_init ncurses_slk_noutrefresh ncurses_slk_refresh ncurses_slk_restore ncurses_slk_set ncurses_slk_touch  contained
syn keyword phpFunctions  ncurses_standend ncurses_standout ncurses_start_color ncurses_termattrs ncurses_termname ncurses_timeout ncurses_top_panel ncurses_typeahead ncurses_ungetch ncurses_ungetmouse ncurses_update_panels ncurses_use_default_colors ncurses_use_env ncurses_use_extended_names ncurses_vidattr ncurses_vline ncurses_waddch ncurses_waddstr ncurses_wattroff ncurses_wattron  contained
syn keyword phpFunctions  ncurses_wattrset ncurses_wborder ncurses_wclear ncurses_wcolor_set ncurses_werase ncurses_wgetch ncurses_whline ncurses_wmouse_trafo ncurses_wmove ncurses_wnoutrefresh ncurses_wrefresh ncurses_wstandend ncurses_wstandout ncurses_wvline newt_bell newt_button newt_button_bar newt_centered_window newt_checkbox newt_checkbox_get_value  contained
syn keyword phpFunctions  newt_checkbox_set_flags newt_checkbox_set_value newt_checkbox_tree newt_checkbox_tree_add_item newt_checkbox_tree_find_item newt_checkbox_tree_get_current newt_checkbox_tree_get_entry_value newt_checkbox_tree_get_multi_selection newt_checkbox_tree_get_selection newt_checkbox_tree_multi newt_checkbox_tree_set_current newt_checkbox_tree_set_entry newt_checkbox_tree_set_entry_value newt_checkbox_tree_set_width newt_clear_key_buffer newt_cls newt_compact_button newt_component_add_callback newt_component_takes_focus newt_create_grid  contained
syn keyword phpFunctions  newt_cursor_off newt_cursor_on newt_delay newt_draw_form newt_draw_root_text newt_entry newt_entry_get_value newt_entry_set newt_entry_set_filter newt_entry_set_flags newt_finished newt_form newt_form_add_component newt_form_add_components newt_form_add_hot_key newt_form_destroy newt_form_get_current newt_form_run newt_form_set_background newt_form_set_height  contained
syn keyword phpFunctions  newt_form_set_size newt_form_set_timer newt_form_set_width newt_form_watch_fd newt_get_screen_size newt_grid_add_components_to_form newt_grid_basic_window newt_grid_free newt_grid_get_size newt_grid_h_close_stacked newt_grid_h_stacked newt_grid_place newt_grid_set_field newt_grid_simple_window newt_grid_v_close_stacked newt_grid_v_stacked newt_grid_wrapped_window newt_grid_wrapped_window_at newt_init newt_label  contained
syn keyword phpFunctions  newt_label_set_text newt_listbox newt_listbox_append_entry newt_listbox_clear newt_listbox_clear_selection newt_listbox_delete_entry newt_listbox_get_current newt_listbox_get_selection newt_listbox_insert_entry newt_listbox_item_count newt_listbox_select_item newt_listbox_set_current newt_listbox_set_current_by_key newt_listbox_set_data newt_listbox_set_entry newt_listbox_set_width newt_listitem newt_listitem_get_data newt_listitem_set newt_open_window  contained
syn keyword phpFunctions  newt_pop_help_line newt_pop_window newt_push_help_line newt_radiobutton newt_radio_get_current newt_redraw_help_line newt_reflow_text newt_refresh newt_resize_screen newt_resume newt_run_form newt_scale newt_scale_set newt_scrollbar_set newt_set_help_callback newt_set_suspend_callback newt_suspend newt_textbox newt_textbox_get_num_lines newt_textbox_reflowed  contained
syn keyword phpFunctions  newt_textbox_set_height newt_textbox_set_text newt_vertical_scrollbar newt_wait_for_key newt_win_choice newt_win_entries newt_win_menu newt_win_message newt_win_messagev newt_win_ternary next ngettext nl2br nl_langinfo NoRewindIterator normalizer_is_normalized normalizer_normalize nsapi_request_headers nsapi_response_headers nsapi_virtual  contained
syn keyword phpFunctions  nthmac number_format numcolumns numfmt_create numfmt_format numfmt_format_currency numfmt_get_attribute numfmt_get_error_code numfmt_get_error_message numfmt_get_locale numfmt_get_pattern numfmt_get_symbol numfmt_get_text_attribute numfmt_parse numfmt_parse_currency numfmt_set_attribute numfmt_set_pattern numfmt_set_symbol numfmt_set_text_attribute numrows  contained
syn keyword phpFunctions  oauth_get_sbs oauth_urlencode ob_clean ob_deflatehandler ob_end_clean ob_end_flush ob_etaghandler ob_flush ob_get_clean ob_get_contents ob_get_flush ob_get_length ob_get_level ob_get_status ob_gzhandler ob_iconv_handler ob_implicit_flush ob_inflatehandler ob_list_handlers ob_start  contained
syn keyword phpFunctions  ob_tidyhandler oci_bind_array_by_name oci_bind_by_name oci_cancel oci_client_version oci_close oci_commit oci_connect oci_define_by_name oci_error oci_execute oci_fetch oci_fetch_all oci_fetch_array oci_fetch_assoc oci_fetch_object oci_fetch_row oci_field_is_null oci_field_name oci_field_precision  contained
syn keyword phpFunctions  oci_field_scale oci_field_size oci_field_type oci_field_type_raw oci_free_descriptor oci_free_statement oci_get_implicit_resultset oci_internal_debug oci_lob_copy oci_lob_is_equal oci_new_collection oci_new_connect oci_new_cursor oci_new_descriptor oci_num_fields oci_num_rows oci_parse oci_password_change oci_pconnect oci_result  contained
syn keyword phpFunctions  oci_rollback oci_server_version oci_set_action oci_set_client_identifier oci_set_client_info oci_set_edition oci_set_module_name oci_set_prefetch oci_statement_type octdec odbc_autocommit odbc_binmode odbc_close odbc_close_all odbc_columnprivileges odbc_columns odbc_commit odbc_connect odbc_cursor odbc_data_source  contained
syn keyword phpFunctions  odbc_error odbc_errormsg odbc_exec odbc_execute odbc_fetch_array odbc_fetch_into odbc_fetch_object odbc_fetch_row odbc_field_len odbc_field_name odbc_field_num odbc_field_scale odbc_field_type odbc_foreignkeys odbc_free_result odbc_gettypeinfo odbc_longreadlen odbc_next_result odbc_num_fields odbc_num_rows  contained
syn keyword phpFunctions  odbc_pconnect odbc_prepare odbc_primarykeys odbc_procedurecolumns odbc_procedures odbc_result odbc_result_all odbc_rollback odbc_setoption odbc_specialcolumns odbc_statistics odbc_tableprivileges odbc_tables opcache_compile_file opcache_get_configuration opcache_get_status opcache_invalidate opcache_is_script_cached opcache_reset openal_buffer_create  contained
syn keyword phpFunctions  openal_buffer_data openal_buffer_destroy openal_buffer_get openal_buffer_loadwav openal_context_create openal_context_current openal_context_destroy openal_context_process openal_context_suspend openal_device_close openal_device_open openal_listener_get openal_listener_set openal_source_create openal_source_destroy openal_source_get openal_source_pause openal_source_play openal_source_rewind openal_source_set  contained
syn keyword phpFunctions  openal_source_stop openal_stream opendir openlog openssl_cipher_iv_length openssl_csr_export openssl_csr_export_to_file openssl_csr_get_public_key openssl_csr_get_subject openssl_csr_new openssl_csr_sign openssl_decrypt openssl_dh_compute_key openssl_digest openssl_encrypt openssl_error_string openssl_free_key openssl_get_cert_locations openssl_get_cipher_methods openssl_get_md_methods  contained
syn keyword phpFunctions  openssl_open openssl_pbkdf2 openssl_pkcs12_export openssl_pkcs12_export_to_file openssl_pkcs12_read openssl_pkcs7_decrypt openssl_pkcs7_encrypt openssl_pkcs7_sign openssl_pkcs7_verify openssl_pkey_export openssl_pkey_export_to_file openssl_pkey_free openssl_pkey_get_details openssl_pkey_get_private openssl_pkey_get_public openssl_pkey_new openssl_private_decrypt openssl_private_encrypt openssl_public_decrypt openssl_public_encrypt  contained
syn keyword phpFunctions  openssl_random_pseudo_bytes openssl_seal openssl_sign openssl_spki_export openssl_spki_export_challenge openssl_spki_new openssl_spki_verify openssl_verify openssl_x509_check_private_key openssl_x509_checkpurpose openssl_x509_export openssl_x509_export_to_file openssl_x509_fingerprint openssl_x509_free openssl_x509_parse openssl_x509_read ord output_add_rewrite_var output_reset_rewrite_vars override_function  contained
syn keyword phpFunctions  pack parsecommadelimited parse_ini_file parse_ini_string parsekit_compile_file parsekit_compile_string parsekit_func_arginfo parse_str parse_url passthru password_get_info password_hash password_needs_rehash password_verify pathinfo pclose pcntl_alarm pcntl_exec pcntl_fork pcntl_get_last_error  contained
syn keyword phpFunctions  pcntl_getpriority pcntl_setpriority pcntl_signal pcntl_signal_dispatch pcntl_sigprocmask pcntl_sigtimedwait pcntl_sigwaitinfo pcntl_strerror pcntl_wait pcntl_waitpid pcntl_wexitstatus pcntl_wifexited pcntl_wifsignaled pcntl_wifstopped pcntl_wstopsig pcntl_wtermsig PDF_activate_item PDF_add_launchlink PDF_add_locallink PDF_add_nameddest  contained
syn keyword phpFunctions  PDF_add_note PDF_add_pdflink PDF_add_table_cell PDF_add_textflow PDF_add_thumbnail PDF_add_weblink PDF_arc PDF_arcn PDF_attach_file PDF_begin_document PDF_begin_font PDF_begin_glyph PDF_begin_item PDF_begin_layer PDF_begin_page PDF_begin_page_ext PDF_begin_pattern PDF_begin_template PDF_begin_template_ext PDF_circle  contained
syn keyword phpFunctions  PDF_clip PDF_close PDF_close_image PDF_closepath PDF_closepath_fill_stroke PDF_closepath_stroke PDF_close_pdi PDF_close_pdi_page PDF_concat PDF_continue_text PDF_create_3dview PDF_create_action PDF_create_annotation PDF_create_bookmark PDF_create_field PDF_create_fieldgroup PDF_create_gstate PDF_create_pvf PDF_create_textflow PDF_curveto  contained
syn keyword phpFunctions  PDF_define_layer PDF_delete PDF_delete_pvf PDF_delete_table PDF_delete_textflow PDF_encoding_set_char PDF_end_document PDF_end_font PDF_end_glyph PDF_end_item PDF_end_layer PDF_end_page PDF_end_page_ext PDF_endpath PDF_end_pattern PDF_end_template PDF_fill PDF_fill_imageblock PDF_fill_pdfblock PDF_fill_stroke  contained
syn keyword phpFunctions  PDF_fill_textblock PDF_findfont PDF_fit_image PDF_fit_pdi_page PDF_fit_table PDF_fit_textflow PDF_fit_textline PDF_get_apiname PDF_get_buffer PDF_get_errmsg PDF_get_errnum PDF_get_majorversion PDF_get_minorversion PDF_get_parameter PDF_get_pdi_parameter PDF_get_pdi_value PDF_get_value PDF_info_font PDF_info_matchbox PDF_info_table  contained
syn keyword phpFunctions  PDF_info_textflow PDF_info_textline PDF_initgraphics PDF_lineto PDF_load_3ddata PDF_load_font PDF_load_iccprofile PDF_load_image PDF_makespotcolor PDF_moveto PDF_new PDF_open_ccitt PDF_open_file PDF_open_image PDF_open_image_file PDF_open_memory_image PDF_open_pdi PDF_open_pdi_document PDF_open_pdi_page PDF_pcos_get_number  contained
syn keyword phpFunctions  PDF_pcos_get_stream PDF_pcos_get_string PDF_place_image PDF_place_pdi_page PDF_process_pdi PDF_rect PDF_restore PDF_resume_page PDF_rotate PDF_save PDF_scale PDF_set_border_color PDF_set_border_dash PDF_set_border_style PDF_setcolor PDF_setdash PDF_setdashpattern PDF_setflat PDF_setfont PDF_setgray  contained
syn keyword phpFunctions  PDF_setgray_fill PDF_setgray_stroke PDF_set_gstate PDF_set_info PDF_set_layer_dependency PDF_setlinecap PDF_setlinejoin PDF_setlinewidth PDF_setmatrix PDF_setmiterlimit PDF_set_parameter PDF_setrgbcolor PDF_setrgbcolor_fill PDF_setrgbcolor_stroke PDF_set_text_pos PDF_set_value PDF_shading PDF_shading_pattern PDF_shfill PDF_show  contained
syn keyword phpFunctions  PDF_show_boxed PDF_show_xy PDF_skew PDF_stringwidth PDF_stroke PDF_suspend_page PDF_translate PDF_utf16_to_utf8 PDF_utf32_to_utf16 PDF_utf8_to_utf16 pdo_drivers pfsockopen pg_affected_rows pg_cancel_query pg_client_encoding pg_close pg_connect pg_connection_busy pg_connection_reset pg_connection_status  contained
syn keyword phpFunctions  pg_connect_poll pg_consume_input pg_convert pg_copy_from pg_copy_to pg_dbname pg_delete pg_end_copy pg_escape_bytea pg_escape_identifier pg_escape_literal pg_escape_string pg_execute pg_fetch_all pg_fetch_all_columns pg_fetch_array pg_fetch_assoc pg_fetch_object pg_fetch_result pg_fetch_row  contained
syn keyword phpFunctions  pg_field_is_null pg_field_name pg_field_num pg_field_prtlen pg_field_size pg_field_table pg_field_type pg_field_type_oid pg_flush pg_free_result pg_get_notify pg_get_pid pg_get_result pg_host pg_insert pg_last_error pg_last_notice pg_last_oid pg_lo_close pg_lo_create  contained
syn keyword phpFunctions  pg_lo_export pg_lo_import pg_lo_open pg_lo_read pg_lo_read_all pg_lo_seek pg_lo_tell pg_lo_truncate pg_lo_unlink pg_lo_write pg_meta_data pg_num_fields pg_num_rows pg_options pg_parameter_status pg_pconnect pg_ping pg_port pg_prepare pg_put_line  contained
syn keyword phpFunctions  pg_query pg_query_params pg_result_error pg_result_error_field pg_result_seek pg_result_status pg_select pg_send_execute pg_send_prepare pg_send_query pg_send_query_params pg_set_client_encoding pg_set_error_verbosity pg_socket pg_trace pg_transaction_status pg_tty pg_unescape_bytea pg_untrace pg_update  contained
syn keyword phpFunctions  pg_version php_check_syntax phpcredits phpinfo php_ini_loaded_file php_ini_scanned_files php_logo_guid php_sapi_name php_strip_whitespace php_uname phpversion pi png2wbmp popen posix_access posix_ctermid posix_getcwd posix_getegid posix_geteuid posix_getgid  contained
syn keyword phpFunctions  posix_getgrgid posix_getgrnam posix_getgroups posix_get_last_error posix_getlogin posix_getpgid posix_getpgrp posix_getpid posix_getppid posix_getpwnam posix_getpwuid posix_getrlimit posix_getsid posix_getuid posix_initgroups posix_isatty posix_kill posix_mkfifo posix_mknod posix_setegid  contained
syn keyword phpFunctions  posix_seteuid posix_setgid posix_setpgid posix_setrlimit posix_setsid posix_setuid posix_strerror posix_times posix_ttyname posix_uname pow preg_filter preg_grep preg_last_error preg_match preg_match_all preg_quote preg_replace preg_replace_callback preg_replace_callback_array  contained
syn keyword phpFunctions  preg_split prev print printf print_r proc_close proc_get_status proc_nice proc_open proc_terminate property_exists ps_add_bookmark ps_add_launchlink ps_add_locallink ps_add_note ps_add_pdflink ps_add_weblink ps_arc ps_arcn ps_begin_page  contained
syn keyword phpFunctions  ps_begin_pattern ps_begin_template ps_circle ps_clip ps_close ps_close_image ps_closepath ps_closepath_stroke ps_continue_text ps_curveto ps_delete ps_end_page ps_end_pattern ps_end_template ps_fill ps_fill_stroke ps_findfont ps_get_buffer ps_get_parameter ps_get_value  contained
syn keyword phpFunctions  ps_hyphenate ps_include_file ps_lineto ps_makespotcolor ps_moveto ps_new ps_open_file ps_open_image ps_open_image_file ps_open_memory_image pspell_add_to_personal pspell_add_to_session pspell_check pspell_clear_session pspell_config_create pspell_config_data_dir pspell_config_dict_dir pspell_config_ignore pspell_config_mode pspell_config_personal  contained
syn keyword phpFunctions  pspell_config_repl pspell_config_runtogether pspell_config_save_repl pspell_new pspell_new_config pspell_new_personal pspell_save_wordlist pspell_store_replacement pspell_suggest ps_place_image ps_rect ps_restore ps_rotate ps_save ps_scale ps_set_border_color ps_set_border_dash ps_set_border_style ps_setcolor ps_setdash  contained
syn keyword phpFunctions  ps_setflat ps_setfont ps_setgray ps_set_info ps_setlinecap ps_setlinejoin ps_setlinewidth ps_setmiterlimit ps_setoverprintmode ps_set_parameter ps_setpolydash ps_set_text_pos ps_set_value ps_shading ps_shading_pattern ps_shfill ps_show ps_show2 ps_show_boxed ps_show_xy  contained
syn keyword phpFunctions  ps_show_xy2 ps_string_geometry ps_stringwidth ps_stroke ps_symbol ps_symbol_name ps_symbol_width ps_translate putenv px_close px_create_fp px_date2string px_delete px_delete_record px_get_field px_get_info px_get_parameter px_get_record px_get_schema px_get_value  contained
syn keyword phpFunctions  px_insert_record px_new px_numfields px_numrecords px_open_fp px_put_record px_retrieve_record px_set_blob_file px_set_parameter px_set_tablename px_set_targetencoding px_set_value px_timestamp2string px_update_record quoted_printable_decode quoted_printable_encode quotemeta rad2deg radius_acct_open radius_add_server  contained
syn keyword phpFunctions  radius_auth_open radius_close radius_config radius_create_request radius_cvt_addr radius_cvt_int radius_cvt_string radius_demangle radius_demangle_mppe_key radius_get_attr radius_get_tagged_attr_data radius_get_tagged_attr_tag radius_get_vendor_attr radius_put_addr radius_put_attr radius_put_int radius_put_string radius_put_vendor_addr radius_put_vendor_attr radius_put_vendor_int  contained
syn keyword phpFunctions  radius_put_vendor_string radius_request_authenticator radius_salt_encrypt_attr radius_send_request radius_server_secret radius_strerror rand random_bytes random_int range rar_allow_broken_set rar_broken_is rar_close rar_comment_get rar_entry_get rar_list rar_open rar_solid_is rar_wrapper_cache_stats rawurldecode  contained
syn keyword phpFunctions  rawurlencode readdir readfile readgzfile readline readline_add_history readline_callback_handler_install readline_callback_handler_remove readline_callback_read_char readline_clear_history readline_completion_function readline_info readline_list_history readline_on_new_line readline_read_history readline_redisplay readline_write_history readlink realpath realpath_cache_get  contained
syn keyword phpFunctions  realpath_cache_size recode_file recode_string RecursiveDirectoryIterator RecursiveFilterIterator RecursiveIterator register_shutdown_function register_tick_function rename rename_function reset resourcebundle_count resourcebundle_create resourcebundle_get resourcebundle_get_error_code resourcebundle_get_error_message resourcebundle_locales responsekeys responseparam restore_error_handler  contained
syn keyword phpFunctions  restore_exception_handler restore_include_path returnstatus rewind rewinddir rmdir round rpm_close rpm_get_tag rpm_is_valid rpm_open rpm_version rrdc_disconnect rrd_create rrd_error rrd_fetch rrd_first rrd_graph rrd_info rrd_last  contained
syn keyword phpFunctions  rrd_lastupdate rrd_restore rrd_tune rrd_update rrd_version rrd_xport rsort rtrim runkit_class_adopt runkit_class_emancipate runkit_constant_add runkit_constant_redefine runkit_constant_remove runkit_function_add runkit_function_copy runkit_function_redefine runkit_function_remove runkit_function_rename runkit_import runkit_lint  contained
syn keyword phpFunctions  runkit_lint_file runkit_method_add runkit_method_copy runkit_method_redefine runkit_method_remove runkit_method_rename runkit_return_value_used runkit_sandbox_output_handler runkit_superglobals scandir sem_acquire sem_get sem_release sem_remove serialize session_abort session_cache_expire session_cache_limiter session_decode session_destroy  contained
syn keyword phpFunctions  session_encode session_get_cookie_params session_id session_is_registered session_module_name session_name session_pgsql_add_error session_pgsql_get_error session_pgsql_get_field session_pgsql_reset session_pgsql_set_field session_pgsql_status session_regenerate_id session_register session_register_shutdown session_reset session_save_path session_set_cookie_params session_set_save_handler session_start  contained
syn keyword phpFunctions  session_status session_unregister session_unset session_write_close set setblocking setcookie setdropfile set_error_handler set_exception_handler set_include_path setip setLeftFill setLine setlocale set_magic_quotes_runtime setproctitle setrawcookie setRightFill setssl  contained
syn keyword phpFunctions  setssl_cafile setssl_files set_state setthreadtitle set_time_limit settimeout settype sha1 sha1_file shell_exec shm_attach shm_detach shm_get_var shm_has_var shmop_close shmop_delete shmop_open shmop_read shmop_size shmop_write  contained
syn keyword phpFunctions  shm_put_var shm_remove shm_remove_var shuffle similar_text simplexml_import_dom simplexml_load_file simplexml_load_string sin sinh sleep snmp2_get snmp2_getnext snmp2_real_walk snmp2_set snmp2_walk snmp3_get snmp3_getnext snmp3_real_walk snmp3_set  contained
syn keyword phpFunctions  snmp3_walk snmpget snmpgetnext snmp_get_quick_print snmp_get_valueretrieval snmp_read_mib snmprealwalk snmpset snmp_set_enum_print snmp_set_oid_numeric_print snmp_set_oid_output_format snmp_set_quick_print snmp_set_valueretrieval snmpwalk snmpwalkoid socket_accept socket_bind socket_clear_error socket_close socket_cmsg_space  contained
syn keyword phpFunctions  socket_connect socket_create socket_create_listen socket_create_pair socket_get_option socket_getpeername socket_getsockname socket_import_stream socket_last_error socket_listen socket_read socket_recv socket_recvfrom socket_recvmsg socket_select socket_send socket_sendmsg socket_sendto socket_set_block socket_set_nonblock  contained
syn keyword phpFunctions  socket_set_option socket_shutdown socket_strerror socket_write solr_get_version sort soundex spl_autoload spl_autoload_call spl_autoload_extensions spl_autoload_functions spl_autoload_register spl_autoload_unregister spl_classes split spliti spl_object_hash SplTempFileObject sprintf sqlite_array_query  contained
syn keyword phpFunctions  sqlite_busy_timeout sqlite_changes sqlite_close sqlite_column sqlite_create_aggregate sqlite_create_function sqlite_current sqlite_error_string sqlite_escape_string sqlite_exec sqlite_factory sqlite_fetch_all sqlite_fetch_array sqlite_fetch_column_types sqlite_fetch_object sqlite_fetch_single sqlite_field_name sqlite_has_more sqlite_has_prev sqlite_last_error  contained
syn keyword phpFunctions  sqlite_last_insert_rowid sqlite_libencoding sqlite_libversion sqlite_next sqlite_num_fields sqlite_num_rows sqlite_open sqlite_popen sqlite_prev sqlite_query sqlite_rewind sqlite_seek sqlite_single_query sqlite_udf_decode_binary sqlite_udf_encode_binary sqlite_unbuffered_query sqlite_valid sql_regcase sqlsrv_begin_transaction sqlsrv_cancel  contained
syn keyword phpFunctions  sqlsrv_client_info sqlsrv_close sqlsrv_commit sqlsrv_configure sqlsrv_connect sqlsrv_errors sqlsrv_execute sqlsrv_fetch sqlsrv_fetch_array sqlsrv_fetch_object sqlsrv_field_metadata sqlsrv_free_stmt sqlsrv_get_config sqlsrv_get_field sqlsrv_has_rows sqlsrv_next_result sqlsrv_num_fields sqlsrv_num_rows sqlsrv_prepare sqlsrv_query  contained
syn keyword phpFunctions  sqlsrv_rollback sqlsrv_rows_affected sqlsrv_send_stream_data sqlsrv_server_info sqrt srand sscanf ssdeep_fuzzy_compare ssdeep_fuzzy_hash ssdeep_fuzzy_hash_filename ssh2_auth_agent ssh2_auth_hostbased_file ssh2_auth_none ssh2_auth_password ssh2_auth_pubkey_file ssh2_connect ssh2_exec ssh2_fetch_stream ssh2_fingerprint ssh2_methods_negotiated  contained
syn keyword phpFunctions  ssh2_publickey_add ssh2_publickey_init ssh2_publickey_list ssh2_publickey_remove ssh2_scp_recv ssh2_scp_send ssh2_sftp ssh2_sftp_chmod ssh2_sftp_lstat ssh2_sftp_mkdir ssh2_sftp_readlink ssh2_sftp_realpath ssh2_sftp_rename ssh2_sftp_rmdir ssh2_sftp_stat ssh2_sftp_symlink ssh2_sftp_unlink ssh2_shell ssh2_tunnel sslcert_gen_hash  contained
syn keyword phpFunctions  stat stats_absolute_deviation stats_cdf_beta stats_cdf_binomial stats_cdf_cauchy stats_cdf_chisquare stats_cdf_exponential stats_cdf_f stats_cdf_gamma stats_cdf_laplace stats_cdf_logistic stats_cdf_negative_binomial stats_cdf_noncentral_chisquare stats_cdf_noncentral_f stats_cdf_poisson stats_cdf_t stats_cdf_uniform stats_cdf_weibull stats_covariance stats_dens_beta  contained
syn keyword phpFunctions  stats_dens_cauchy stats_dens_chisquare stats_dens_exponential stats_dens_f stats_dens_gamma stats_dens_laplace stats_dens_logistic stats_dens_negative_binomial stats_dens_normal stats_dens_pmf_binomial stats_dens_pmf_hypergeometric stats_dens_pmf_poisson stats_dens_t stats_dens_weibull stats_den_uniform stats_harmonic_mean stats_kurtosis stats_rand_gen_beta stats_rand_gen_chisquare stats_rand_gen_exponential  contained
syn keyword phpFunctions  stats_rand_gen_f stats_rand_gen_funiform stats_rand_gen_gamma stats_rand_gen_ibinomial stats_rand_gen_ibinomial_negative stats_rand_gen_int stats_rand_gen_ipoisson stats_rand_gen_iuniform stats_rand_gen_noncenral_chisquare stats_rand_gen_noncentral_f stats_rand_gen_noncentral_t stats_rand_gen_normal stats_rand_gen_t stats_rand_get_seeds stats_rand_phrase_to_seeds stats_rand_ranf stats_rand_setall stats_skew stats_standard_deviation stats_stat_binomial_coef  contained
syn keyword phpFunctions  stats_stat_correlation stats_stat_gennch stats_stat_independent_t stats_stat_innerproduct stats_stat_noncentral_t stats_stat_paired_t stats_stat_percentile stats_stat_powersum stats_variance stomp_abort stomp_ack stomp_begin stomp_close stomp_commit stomp_connect stomp_connect_error stomp_error stomp_get_read_timeout stomp_get_session_id stomp_has_frame  contained
syn keyword phpFunctions  stomp_read_frame stomp_send stomp_set_read_timeout stomp_subscribe stomp_unsubscribe stomp_version strcasecmp strcmp strcoll strcspn stream_bucket_append stream_bucket_make_writeable stream_bucket_new stream_bucket_prepend stream_context_create stream_context_get_default stream_context_get_options stream_context_get_params stream_context_set_default stream_context_set_option  contained
syn keyword phpFunctions  stream_context_set_params stream_copy_to_stream stream_encoding stream_filter_append stream_filter_prepend stream_filter_register stream_filter_remove stream_get_contents stream_get_filters stream_get_line stream_get_meta_data stream_get_transports stream_get_wrappers stream_is_local stream_resolve_include_path stream_select stream_set_blocking stream_set_chunk_size stream_set_read_buffer stream_set_timeout  contained
syn keyword phpFunctions  stream_set_write_buffer stream_socket_accept stream_socket_client stream_socket_enable_crypto stream_socket_get_name stream_socket_pair stream_socket_recvfrom stream_socket_sendto stream_socket_server stream_socket_shutdown stream_supports_lock stream_wrapper_register stream_wrapper_restore stream_wrapper_unregister strftime str_getcsv stripcslashes stripos stripslashes strip_tags  contained
syn keyword phpFunctions  str_ireplace stristr strlen strnatcasecmp strnatcmp strncasecmp strncmp str_pad strpbrk strpos strptime strrchr str_repeat str_replace strrev strripos str_rot13 strrpos str_shuffle str_split  contained
syn keyword phpFunctions  strspn strstr strtok strtolower strtotime strtoupper strtr strval str_word_count substr substr_compare substr_count substr_replace svn_add svn_auth_get_parameter svn_auth_set_parameter svn_blame svn_cat svn_checkout svn_cleanup  contained
syn keyword phpFunctions  svn_client_version svn_commit svn_delete svn_diff svn_export svn_fs_abort_txn svn_fs_apply_text svn_fs_begin_txn2 svn_fs_change_node_prop svn_fs_check_path svn_fs_contents_changed svn_fs_copy svn_fs_delete svn_fs_dir_entries svn_fs_file_contents svn_fs_file_length svn_fs_is_dir svn_fs_is_file svn_fs_make_dir svn_fs_make_file  contained
syn keyword phpFunctions  svn_fs_node_created_rev svn_fs_node_prop svn_fs_props_changed svn_fs_revision_prop svn_fs_revision_root svn_fs_txn_root svn_fs_youngest_rev svn_import svn_log svn_ls svn_mkdir svn_repos_create svn_repos_fs svn_repos_fs_begin_txn_for_commit svn_repos_fs_commit_txn svn_repos_hotcopy svn_repos_open svn_repos_recover svn_revert svn_status  contained
syn keyword phpFunctions  svn_update sybase_affected_rows sybase_close sybase_connect sybase_data_seek sybase_deadlock_retry_count sybase_fetch_array sybase_fetch_assoc sybase_fetch_field sybase_fetch_object sybase_fetch_row sybase_field_seek sybase_free_result sybase_get_last_message sybase_min_client_severity sybase_min_error_severity sybase_min_message_severity sybase_min_server_severity sybase_num_fields sybase_num_rows  contained
syn keyword phpFunctions  sybase_pconnect sybase_query sybase_result sybase_select_db sybase_set_message_handler sybase_unbuffered_query symlink sys_getloadavg sys_get_temp_dir syslog system taint tan tanh tcpwrap_check tempnam textdomain tidy_access_count tidy_clean_repair tidy_config_count  contained
syn keyword phpFunctions  tidy_diagnose tidy_error_count tidy_get_body tidy_get_config tidy_get_error_buffer tidy_get_head tidy_get_html tidy_get_html_ver tidy_getopt tidy_get_opt_doc tidy_get_output tidy_get_release tidy_get_root tidy_get_status tidy_is_xhtml tidy_is_xml tidy_load_config tidy_parse_file tidy_parse_string tidy_repair_file  contained
syn keyword phpFunctions  tidy_repair_string tidy_reset_config tidy_save_config tidy_set_encoding tidy_setopt tidy_warning_count time time_nanosleep time_sleep_until timezone_name_from_abbr timezone_version_get tmpfile token_get_all token_name toString touch trader_acos trader_ad trader_add trader_adosc  contained
syn keyword phpFunctions  trader_adx trader_adxr trader_apo trader_aroon trader_aroonosc trader_asin trader_atan trader_atr trader_avgprice trader_bbands trader_beta trader_bop trader_cci trader_cdl2crows trader_cdl3blackcrows trader_cdl3inside trader_cdl3linestrike trader_cdl3outside trader_cdl3starsinsouth trader_cdl3whitesoldiers  contained
syn keyword phpFunctions  trader_cdlabandonedbaby trader_cdladvanceblock trader_cdlbelthold trader_cdlbreakaway trader_cdlclosingmarubozu trader_cdlconcealbabyswall trader_cdlcounterattack trader_cdldarkcloudcover trader_cdldoji trader_cdldojistar trader_cdldragonflydoji trader_cdlengulfing trader_cdleveningdojistar trader_cdleveningstar trader_cdlgapsidesidewhite trader_cdlgravestonedoji trader_cdlhammer trader_cdlhangingman trader_cdlharami trader_cdlharamicross  contained
syn keyword phpFunctions  trader_cdlhighwave trader_cdlhikkake trader_cdlhikkakemod trader_cdlhomingpigeon trader_cdlidentical3crows trader_cdlinneck trader_cdlinvertedhammer trader_cdlkicking trader_cdlkickingbylength trader_cdlladderbottom trader_cdllongleggeddoji trader_cdllongline trader_cdlmarubozu trader_cdlmatchinglow trader_cdlmathold trader_cdlmorningdojistar trader_cdlmorningstar trader_cdlonneck trader_cdlpiercing trader_cdlrickshawman  contained
syn keyword phpFunctions  trader_cdlrisefall3methods trader_cdlseparatinglines trader_cdlshootingstar trader_cdlshortline trader_cdlspinningtop trader_cdlstalledpattern trader_cdlsticksandwich trader_cdltakuri trader_cdltasukigap trader_cdlthrusting trader_cdltristar trader_cdlunique3river trader_cdlupsidegap2crows trader_cdlxsidegap3methods trader_ceil trader_cmo trader_correl trader_cos trader_cosh trader_dema  contained
syn keyword phpFunctions  trader_div trader_dx trader_ema trader_errno trader_exp trader_floor trader_get_compat trader_get_unstable_period trader_ht_dcperiod trader_ht_dcphase trader_ht_phasor trader_ht_sine trader_ht_trendline trader_ht_trendmode trader_kama trader_linearreg trader_linearreg_angle trader_linearreg_intercept trader_linearreg_slope trader_ln  contained
syn keyword phpFunctions  trader_log10 trader_ma trader_macd trader_macdext trader_macdfix trader_mama trader_mavp trader_max trader_maxindex trader_medprice trader_mfi trader_midpoint trader_midprice trader_min trader_minindex trader_minmax trader_minmaxindex trader_minus_di trader_minus_dm trader_mom  contained
syn keyword phpFunctions  trader_mult trader_natr trader_obv trader_plus_di trader_plus_dm trader_ppo trader_roc trader_rocp trader_rocr trader_rocr100 trader_rsi trader_sar trader_sarext trader_set_compat trader_set_unstable_period trader_sin trader_sinh trader_sma trader_sqrt trader_stddev  contained
syn keyword phpFunctions  trader_stoch trader_stochf trader_stochrsi trader_sub trader_sum trader_t3 trader_tan trader_tanh trader_tema trader_trange trader_trima trader_trix trader_tsf trader_typprice trader_ultosc trader_var trader_wclprice trader_willr trader_wma trait_exists  contained
syn keyword phpFunctions  transactionssent transinqueue transkeyval transliterator_create transliterator_create_from_rules transliterator_create_inverse transliterator_get_error_code transliterator_get_error_message transliterator_list_ids transliterator_transliterate transnew transsend trigger_error trim uasort ucfirst ucwords udm_add_search_limit udm_alloc_agent udm_alloc_agent_array  contained
syn keyword phpFunctions  udm_api_version udm_cat_list udm_cat_path udm_check_charset udm_clear_search_limits udm_crc32 udm_errno udm_error udm_find udm_free_agent udm_free_ispell_data udm_free_res udm_get_doc_count udm_get_res_field udm_get_res_param udm_hash32 udm_load_ispell_data udm_set_agent_param uksort umask  contained
syn keyword phpFunctions  uniqid unixtojd unlink unpack unregister_tick_function unserialize unset untaint uopz_backup uopz_compose uopz_copy uopz_delete uopz_extend uopz_flags uopz_function uopz_implement uopz_overload uopz_redefine uopz_rename uopz_restore  contained
syn keyword phpFunctions  uopz_undefine urldecode urlencode use_soap_error_handler usleep usort utf8_decode utf8_encode uwait validateidentifier var_dump var_export variant_abs variant_add variant_and variant_cast variant_cat variant_cmp variant_date_from_timestamp variant_date_to_timestamp  contained
syn keyword phpFunctions  variant_div variant_eqv variant_fix variant_get_type variant_idiv variant_imp variant_int variant_mod variant_mul variant_neg variant_not variant_or variant_pow variant_round variant_set variant_set_type variant_sub variant_xor verifyconnection verifysslcert  contained
syn keyword phpFunctions  version_compare vfprintf virtual vpopmail_add_alias_domain vpopmail_add_alias_domain_ex vpopmail_add_domain vpopmail_add_domain_ex vpopmail_add_user vpopmail_alias_add vpopmail_alias_del vpopmail_alias_del_domain vpopmail_alias_get vpopmail_alias_get_all vpopmail_auth_user vpopmail_del_domain vpopmail_del_domain_ex vpopmail_del_user vpopmail_error vpopmail_passwd vpopmail_set_user_quota  contained
syn keyword phpFunctions  vprintf vsprintf wakeup wddx_add_vars wddx_deserialize wddx_packet_end wddx_packet_start wddx_serialize_value wddx_serialize_vars win32_continue_service win32_create_service win32_delete_service win32_get_last_control_message win32_pause_service win32_ps_list_procs win32_ps_stat_mem win32_ps_stat_proc win32_query_service_status win32_set_service_status win32_start_service  contained
syn keyword phpFunctions  win32_start_service_ctrl_dispatcher win32_stop_service wincache_fcache_fileinfo wincache_fcache_meminfo wincache_lock wincache_ocache_fileinfo wincache_ocache_meminfo wincache_refresh_if_changed wincache_rplist_fileinfo wincache_rplist_meminfo wincache_scache_info wincache_scache_meminfo wincache_ucache_add wincache_ucache_cas wincache_ucache_clear wincache_ucache_dec wincache_ucache_delete wincache_ucache_exists wincache_ucache_get wincache_ucache_inc  contained
syn keyword phpFunctions  wincache_ucache_info wincache_ucache_meminfo wincache_ucache_set wincache_unlock wordwrap xattr_get xattr_list xattr_remove xattr_set xattr_supported xdiff_file_bdiff xdiff_file_bdiff_size xdiff_file_bpatch xdiff_file_diff xdiff_file_diff_binary xdiff_file_merge3 xdiff_file_patch xdiff_file_patch_binary xdiff_file_rabdiff xdiff_string_bdiff  contained
syn keyword phpFunctions  xdiff_string_bdiff_size xdiff_string_bpatch xdiff_string_diff xdiff_string_merge3 xdiff_string_patch xdiff_string_patch_binary xhprof_disable xhprof_enable xhprof_sample_disable xhprof_sample_enable xml_error_string xml_get_current_byte_index xml_get_current_column_number xml_get_current_line_number xml_get_error_code xml_parse xml_parse_into_struct xml_parser_create xml_parser_create_ns xml_parser_free  contained
syn keyword phpFunctions  xml_parser_get_option xml_parser_set_option xmlrpc_decode xmlrpc_decode_request xmlrpc_encode xmlrpc_encode_request xmlrpc_get_type xmlrpc_is_fault xmlrpc_parse_method_descriptions xmlrpc_server_add_introspection_data xmlrpc_server_call_method xmlrpc_server_create xmlrpc_server_destroy xmlrpc_server_register_introspection_callback xmlrpc_server_register_method xmlrpc_set_type xml_set_character_data_handler xml_set_default_handler xml_set_element_handler xml_set_end_namespace_decl_handler  contained
syn keyword phpFunctions  xml_set_external_entity_ref_handler xml_set_notation_decl_handler xml_set_object xml_set_processing_instruction_handler xml_set_start_namespace_decl_handler xml_set_unparsed_entity_decl_handler xmlwriter_end_attribute xmlwriter_end_cdata xmlwriter_end_comment xmlwriter_end_document xmlwriter_end_dtd xmlwriter_end_dtd_attlist xmlwriter_end_dtd_element xmlwriter_end_dtd_entity xmlwriter_end_element xmlwriter_end_pi xmlwriter_flush xmlwriter_full_end_element xmlwriter_open_memory xmlwriter_open_uri  contained
syn keyword phpFunctions  xmlwriter_output_memory xmlwriter_set_indent xmlwriter_set_indent_string xmlwriter_start_attribute xmlwriter_start_attribute_ns xmlwriter_start_cdata xmlwriter_start_comment xmlwriter_start_document xmlwriter_start_dtd xmlwriter_start_dtd_attlist xmlwriter_start_dtd_element xmlwriter_start_dtd_entity xmlwriter_start_element xmlwriter_start_element_ns xmlwriter_start_pi xmlwriter_text xmlwriter_write_attribute xmlwriter_write_attribute_ns xmlwriter_write_cdata xmlwriter_write_comment  contained
syn keyword phpFunctions  xmlwriter_write_dtd xmlwriter_write_dtd_attlist xmlwriter_write_dtd_element xmlwriter_write_dtd_entity xmlwriter_write_element xmlwriter_write_element_ns xmlwriter_write_pi xmlwriter_write_raw Yaf_Application yaml_emit yaml_emit_file yaml_parse yaml_parse_file yaml_parse_url yaz_addinfo yaz_ccl_conf yaz_ccl_parse yaz_close yaz_connect yaz_database  contained
syn keyword phpFunctions  yaz_element yaz_errno yaz_error yaz_es yaz_es_result yaz_get_option yaz_hits yaz_itemorder yaz_present yaz_range yaz_record yaz_scan yaz_scan_result yaz_schema yaz_search yaz_set_option yaz_sort yaz_syntax yaz_wait yp_all  contained
syn keyword phpFunctions  yp_cat yp_errno yp_err_string yp_first yp_get_default_domain yp_master yp_match yp_next yp_order zend_logo_guid zend_thread_id zend_version zip_close zip_entry_close zip_entry_compressedsize zip_entry_compressionmethod zip_entry_filesize zip_entry_name zip_entry_open zip_entry_read  contained
syn keyword phpFunctions  zip_open zip_read zlib_decode zlib_encode zlib_get_coding_type  contained

syn keyword phpMethods  abort accept acceptFromHttp ack acquire adaptiveBlurImage adaptiveResizeImage adaptiveSharpenImage adaptiveThresholdImage add addAction addAll addArchive addASound addAttribute addBigramPhraseField addBigramPhraseFields addBoostQuery addBuffer addByKey  contained
syn keyword phpMethods  addChars addChild addColor addColorStopRgb addColorStopRgba addCond addConfig addCookies addDataSource addDocument addDocuments addEmptyDir addEntry addExpandFilterQuery addExpandSortField addExport addFacetDateField addFacetDateOther addFacetField addFacetQuery  contained
syn keyword phpMethods  addField addFile addFill addFilterQuery addFont addFrame addFromString addFunction addGlob addGroupField addGroupFunction addGroupQuery addGroupSortField addHeader addHeaders addHighlightField addimage addImage addKernel addMltField  contained
syn keyword phpMethods  addMltQueryField addNameserverIp addnoiseimage addNoiseImage addOption addOptions addPage addPageLabel addParam addPattern addPhraseField addPhraseFields addPostFields addPostFile addPropertyToType addPutData addQuery addQueryData addQueryField addRawPostData  contained
syn keyword phpMethods  AddRef addRequiredParameter addRoute addSearch addServer addServerAlias addServers addShape addSignal addSoapHeader addSortField addSslOptions addStatsFacet addStatsField addString addTask addTaskBackground addTaskHigh addTaskHighBackground addTaskLow  contained
syn keyword phpMethods  addTaskLowBackground addTaskStatus addTimer addTrigramPhraseField addType addTypes addUnityKernel addUserField addUTF8Chars addUTF8String affine affineTransformImage after again aggregate aggregateCursor align All allowsNull animateImages  contained
syn keyword phpMethods  annotate annotateimage annotateImage annotation apiVersion app append appendBody appendByKey appendChild appendData appendFrom appendImages appendPath appendXML applyChanges arc arcNegative areConfusable arrayQuery  contained
syn keyword phpMethods  asort assemble assign assignElem assignRef asXML at attach attachIterator attr attreditable attr_get attributes attr_set auth authenticate autocommit auto_commit autoLevelImage autoload  contained
syn keyword phpMethods  autoRender availableFonts availableSurfaces averageImages avoidMethod awaitData backend ban banUrl batchInsert batchSize before begin beginChildren beginIteration beginLogging beginText begin_transaction beginTransaction bezier  contained
syn keyword phpMethods  bind bindColumn bind_param bindParam bind_result bindTo bindValue blackThresholdImage blueShiftImage blurimage blurImage body bootstrap borderimage borderImage bottom brightnessContrastImage broadcast bsonSerialize bsonUnserialize  contained
syn keyword phpMethods  buffer buildExcerpts buildFromDirectory buildFromIterator buildKeywords bumpValue busyTimeout byCount C14N C14NFile call __call callconsumerHandler callGetChildren callHasChildren callTimestampNonceHandler calltokenHandler canBePassedByValue cancel canCompress  contained
syn keyword phpMethods  canonicalize canWrite capture cas casByKey catchException changes change_user changeUser character_set_name charAge charcoalimage charcoalImage charDigitValue charDirection charFromName charMirror charName charsetName charType  contained
syn keyword phpMethods  check checkin checkOAuthRequest checkout checkProbabilityModel child children chmod chopimage chopImage chr chunk circle clampImage cleanRepair clear clearBody clearCallbacks clearHeaders clearHistory  contained
syn keyword phpMethods  clearLastError clearLocalNamespace clearPanic clearSearch clip clipExtents clipImage clipImagePath clipPathImage clipPreserve clipRectangleList clone __clone cloneNode close closeConnection closeCursor close_long_data closePath clutImage  contained
syn keyword phpMethods  coalesceImages collapse collect color colorFloodfillImage colorizeImage colorMatrixImage column columnCount columnName columnType combineImages command comment commentimage commentImage commit compare compareImageChannels compareImageLayers  contained
syn keyword phpMethods  compareImages complete composeLocale composite compositeimage compositeImage compress compressAllFilesBZIP2 compressAllFilesGZ compressFiles concat connect connectHost connectUri connectUtil _construct __construct consumerHandler containsIterator  contained
syn keyword phpMethods  content context contrastImage contrastStretchImage convert convertToData convertToExecutable convolveImage copy copyout copyPage copyPath copyPathFlat count countEquivalentIDs countIterators countNameservers country create createAggregate  contained
syn keyword phpMethods  createAttribute createAttributeNS createCDATASection createCharacterInstance createCodePointInstance createCollation createCollection createComment createDataObject createDBRef createDefault createDefaultStub createDestination createDocument createDocumentFragment createDocumentType createElement createElementNS createEntityReference createEnumeration  contained
syn keyword phpMethods  createForData createFromDateString createFromDocument createFromFormat createFromMutable createFromPng createFromRules createFunction createIndex createInstance createInverse createLineInstance createLinkAnnotation createOutline createPair createProcessingInstruction createRootDataObject createSentenceInstance create_sid createSimilar  contained
syn keyword phpMethods  createStopped createTextAnnotation createTextNode createTimeZone createTitleInstance createURLAnnotation createWordInstance cropimage cropImage cropthumbnailimage cropThumbnailImage crossvalidate cubrid_schema current curveTo curveTo2 curveTo3 cyclecolormapimage cycleColormapImage data  contained
syn keyword phpMethods  data_seek dataSize dbstat dcstat dead debug debugDumpParams decipherImage decompress decompressFiles deconstructimages deconstructImages decrement decrementByKey defaultLoop del delete deleteById deleteByIds deleteByKey  contained
syn keyword phpMethods  deleteByQueries deleteByQuery deleteData deleteField deleteImageArtifact deleteImageProperty deleteIndex deleteIndexes deleteMulti deleteMultiByKey deleteName delMetadata delSignal delTimer depth dequeue description deskewImage despeckleimage despeckleImage  contained
syn keyword phpMethods  destroy __destruct detach detachIterator deviceToUser deviceToUserDistance diagnose diff digestXmlResponse digit dir_closedir dir_opendir dir_readdir dir_rewinddir disable disableDebug disable_reads_from_master disableRedirects disableSSLChecks disableView  contained
syn keyword phpMethods  disconnect dispatch dispatchLoopShutdown dispatchLoopStartup display displayImage displayImages distinct distortImage do doBackground doHigh doHighBackground doJobHandle doLow doLowBackground doNormal doQuery __doRequest doStatus  contained
syn keyword phpMethods  drain drawArc drawCircle drawCubic drawCubicTo drawCurve drawCurveTo drawGlyph drawimage drawImage drawLine drawLineTo drop dropCollection dropDB dscBeginPageSetup dscBeginSetup dscComment dstanchors dstofsrcanchor  contained
syn keyword phpMethods  dump_debug_info echo edgeimage edgeImage eigenValues ellipse embed embeddableBackends embedded_server_end embedded_server_start embossimage embossImage enable enableCookies enableDebug enableLocking enableRedirects enableSSLChecks enableView encipherImage  contained
syn keyword phpMethods  endAttribute endCData endChildren endComment endDocument endDTD endDTDAttlist endDTDElement endDTDEntity endElement endIteration endLogging endMask endPath endPI endPSession endText enhanceimage enhanceImage enqueue  contained
syn keyword phpMethods  ensureIndex enumCharNames enumCharTypes environ eof eofill eoFillStroke equal equalizeimage equalizeImage equals erase errno error errorCode errorInfo escapeQueryChars escapeString eval evaluate  contained
syn keyword phpMethods  evaluateImage exception exchangeArray exec execute executeBulkWrite executeCommand executePreparedQuery executeQuery executeString exists exit expand explain export exportImagePixels ext extend extentImage extents  contained
syn keyword phpMethods  extract extractTo factory fail fault feed feedSignal feedSignalEvent fetch fetch_all fetchAll fetch_array fetchArray fetch_assoc fetchColumn fetchColumnTypes fetch_field fetch_field_direct fetch_fields fetch_object  contained
syn keyword phpMethods  fetchObject fetch_row fetchSingle fflush fgetc fgetcsv fgets fgetss field_count fieldDifference fieldExists fieldName fields field_seek file fill fillExtents fillPreserve fillStroke filter  contained
syn keyword phpMethods  filterMatches finalize find findAndModify findHeader findOne finish fire first firstEmpty flattenImages flipimage flipImage flock floodfillPaintImage floodFillPaintImage flopimage flopImage flush flushInstantly  contained
syn keyword phpMethods  foldCase following fontExtents forceError forDigit fork format formatCurrency formatMessage formatObject forward forwardFourierTransformimage fpassthru fputcsv frameimage frameImage fread free free_result freeze  contained
syn keyword phpMethods  from fromArray fromBuiltin fromDateTime fromDateTimeZone fromEnv fromMatrix fromString fromUCallback fscanf fseek fstat ftell ftruncate ftstat fullEndElement function functionImage functionName fwmKeys  contained
syn keyword phpMethods  fwrite fxImage gammaimage gammaImage gaussianBlurImage gc generateSignature generateToken genUid get __get get* getAccessToken getActionName getActualMaximum getActualMinimum getAffectedRows getAlbum getAliases getAllKeys  contained
syn keyword phpMethods  getAllVariants getAntialias getAppDirectory getApplication getArchiveComment getArrayCopy getArrayIterator getArtist getAscent getATime getAttachedRequests getAttr getAttribute getAttributeNo getAttributeNode getAttributeNodeNS getAttributeNs getAttributeNS getAudioProperties getAuthor  contained
syn keyword phpMethods  getAvailable getAvailableDrivers getAvailableLocales getBase getBasename getBaseType getBaseUri getBidiPairedBracket getBinaryRules getBitrate getBitsPerComponent getBlockCode getBody getBoost getBreakIterator getBuffering getBufferSize getById getByIds getByKey  contained
syn keyword phpMethods  getBytes getByteType getCache getCacheControl getCachel getCalendar getCalendarObject getCallback getCanonicalID getCAPath getCapHeight getCause getChangedDataObjects getChangeSummary getChangeType getChannels get_charset getCharSpace getChildren getCircles  contained
syn keyword phpMethods  getClass getClasses getClassNames get_client_info getClipPath getClipRule getClipUnits getClosure getClosureScopeClass getClosureThis getCMYKFill getCMYKStroke getCode getCollectionInfo getCollectionNames getcolor getColor getColorAsString getcolorcount getColorCount  contained
syn keyword phpMethods  getColorQuantum getColorspace getColorSpace getColorStopCount getColorStopRgba getcolorvalue getColorValue getColorValueQuantum getColumnMeta getCombiningClass getCommand getComment getCommentIndex getCommentName getCompressedSize getCompression getCompressionQuality getConfig getConnection getConnections  contained
syn keyword phpMethods  get_connection_stats getConstant getConstants getConstList getConstructor getContainer getContainingType getContainmentProperty getContent getContentDisposition getContentType getController getControllerName getCookie getCookies getcopyright getCopyright getCrc getCRC32 getCreatorId  contained
syn keyword phpMethods  getCsvControl getCTime getCtm getCurrentEncoder getCurrentFont getCurrentFontSize getCurrentIteratorRow getCurrentPage getCurrentPoint getCurrentPos getCurrentRoute getCurrentTextPos getCurrentThread getCurrentThreadId getDash getDashCount getData getDataFactory getDateType getDayOfWeekType  contained
syn keyword phpMethods  getDBRef getDebug getDeclaringClass getDeclaringFunction getDefault getDefaultProperties getDefaultValue getDefaultValueConstantName getDelayed getDelayedByKey getDeletedCount getDependencies getDepth getDescent getDescription getDestinationEncoding getDestinationType getDetails getDeviceOffset getDigestedResponse  contained
syn keyword phpMethods  getDispatcher getDisplayLanguage getDisplayName getDisplayRegion getDisplayScript getDisplayVariant getDnsErrorString getDocComment getDocNamespaces getDocument getDSTSavings getElapsedTicks getElapsedTime getElem getElementById getElementsByTagName getElementsByTagNameNS getEnabled getEncoder getEncodingName  contained
syn keyword phpMethods  getEndLine getEndpoints getEntries getEntry getEnv getEps getEquivalentID getErrno getError getErrorCode getErrorMessage getErrorNumber getErrorString getETag getException getExecutingFile getExecutingGenerator getExecutingLine getExpand getExpandFilterQueries  contained
syn keyword phpMethods  getExpandQuery getExpandRows getExpandSortFields getExtend getExtendedStats getExtension getExtensionName getExtensions GetExternalAttributesIndex getExternalAttributesName getFacet getFacetDateEnd getFacetDateFields getFacetDateGap getFacetDateHardEnd getFacetDateOther getFacetDateStart getFacetFields getFacetLimit getFacetMethod  contained
syn keyword phpMethods  getFacetMinCount getFacetMissing getFacetOffset getFacetPrefix getFacetQueries getFacetSort getFC_NFKC_Closure getFeatures getField getFieldBoost getFieldCount getFieldNames getFields getFile getFileInfo getfilename getFilename getFileName getFiles getFileTime  contained
syn keyword phpMethods  getfillcolor getFillColor getFillingColorSpace getfillopacity getFillOpacity getFillRule getFilter getFilterQueries getFinishedRequests getFirstDayOfWeek getFlags getFlatness getfont getFont getFontFace getFontFamily getFontMatrix getFontName getFontOptions getfontsize  contained
syn keyword phpMethods  getFontSize getFontStretch getfontstyle getFontStyle getfontweight getFontWeight getFormat getFrameList getFrequency getFromIndex getFromName getFromNeuron getFunction getFunctions __getFunctions getGenre getGMode getGMT getGravity getGrayFill  contained
syn keyword phpMethods  getGrayStroke getGreatestMinimum getGridFS getGroup getGroupCachePercent getGroupFacet getGroupFields getGroupFormat getGroupFunctions getGroupLimit getGroupMain getGroupNGroups getGroupOffset getGroupQueries getGroupSortFields getGroupTarget getGroupTruncate getGzip getHash getHeader  contained
syn keyword phpMethods  getHeaders getHeight getHighlight getHighlightAlternateField getHighlightFields getHighlightFormatter getHighlightFragmenter getHighlightFragsize getHighlightHighlightMultiTerm getHighlightMaxAlternateFieldLength getHighlightMaxAnalyzedChars getHighlightMergeContiguous getHighlightRegexMaxAnalyzedChars getHighlightRegexPattern getHighlightRegexSlop getHighlightRequireFieldMatch getHighlightSimplePost getHighlightSimplePre getHighlightSnippets getHighlightUsePhraseHighlighter  contained
syn keyword phpMethods  getHint getHintMetrics getHintStyle getHistory getHomeURL getHorizontalScaling getHost getHostInformation getHostname getHostOs getHosts getHSL getHtmlVer getHttpStatus getHttpStatusMessage getHttpVersion getId getID getID3v1Tag getID3v2Tag  contained
syn keyword phpMethods  getIdleTimeout getImage getImageAlphaChannel getImageArtifact getImageAttribute getimagebackgroundcolor getImageBackgroundColor getImageBlob getimageblueprimary getImageBluePrimary getimagebordercolor getImageBorderColor getimagechanneldepth getImageChannelDepth getImageChannelDistortion getImageChannelDistortions getImageChannelExtrema getImageChannelKurtosis getImageChannelMean getImageChannelRange  contained
syn keyword phpMethods  getImageChannelStatistics getImageClipMask getImageColormapColor getimagecolors getImageColors getimagecolorspace getImageColorspace getimagecompose getImageCompose getImageCompression getImageCompressionQuality getimagedelay getImageDelay getimagedepth getImageDepth getimagedispose getImageDispose getImageDistortion getimageextrema getImageExtrema  contained
syn keyword phpMethods  getimagefilename getImageFilename getimageformat getImageFormat getimagegamma getImageGamma getImageGeometry getImageGravity getimagegreenprimary getImageGreenPrimary getimageheight getImageHeight getimagehistogram getImageHistogram getimageindex getImageIndex getimageinterlacescheme getImageInterlaceScheme getImageInterpolateMethod getimageiterations  contained
syn keyword phpMethods  getImageIterations getImageLength getImageMagickLicense getimagematte getImageMatte getimagemattecolor getImageMatteColor getImageMimeType getImageOrientation getImagePage getImagePixelColor getimageprofile getImageProfile getImageProfiles getImageProperties getImageProperty getimageredprimary getImageRedPrimary getImageRegion getimagerenderingintent  contained
syn keyword phpMethods  getImageRenderingIntent getimageresolution getImageResolution getImagesBlob getimagescene getImageScene getimagesignature getImageSignature getImageSize getImageTicksPerSecond getImageTotalInkDensity getimagetype getImageType getimageunits getImageUnits getImageVirtualPixelMethod getimagewhitepoint getImageWhitePoint getimagewidth getImageWidth  contained
syn keyword phpMethods  getInc getIndex getIndexInfo getInfo getInfoAttr getINIEntries getInnerIterator getInode getInput getInputBuffer getInputDocument getInputHeaders getInsertedCount getInstance getInstanceProperties getInterfaceNames getInterfaces getInterlaceScheme getInternalInfo getIntPropertyMaxValue  contained
syn keyword phpMethods  getIntPropertyMinValue getIntPropertyValue getInvokeArg getInvokeArgs getIterator getIteratorClass getIteratorIndex getIteratorMode getIteratorRow getJsFileName getJsLineNumber getJsSourceLine getJsTrace getKeywords getKeywordValuesForLocale getLabels getLanguage getLastCodePoint getLastElapsedTicks getLastElapsedTime  contained
syn keyword phpMethods  getLastError getLastErrorMsg getLastErrorNo getLastErrors getLastInsertId getLastMessage getLastModified __getLastRequest __getLastRequestHeaders getLastResponse __getLastResponse getLastResponseHeaders __getLastResponseHeaders getLastResponseInfo getLastSocketErrno getLastSocketError getLastWarning getLatency getLayer getLeading  contained
syn keyword phpMethods  getLeastMaximum getLength getLevel getLevels getLibraryPath getLine getLineCap getLineJoin getLineNo getLineWidth getLinkTarget getListIndex getLocale getLocales getLocalNamespace getLocation getLoop getMatchedCount getMatrix getMax  contained
syn keyword phpMethods  getMaxDepth getMaximum getMaxLineLen getMessage getMeta getMetadata getMetaList getMethod getMethods getMimeType getMin getMinimalDaysInFirstWeek getMinimum getMiterLimit getMlt getMltBoost getMltCount getMltFields getMltMaxNumQueryTerms getMltMaxNumTokens  contained
syn keyword phpMethods  getMltMaxWordLength getMltMinDocFrequency getMltMinTermFrequency getMltMinWordLength getMltQueryFields getMode getModified getModifiedCount getModifierNames getModifiers getModule getModuleName getModules getMTime getMulti getMultiByKey getName getNamed getNamedItem getNamedItemNS  contained
syn keyword phpMethods  getNameIndex getNamespaceName getNamespaces getNamespaceURI getnext getNext getNextIteratorRow getNodePath getNow getNrClass getNullPolicy getNumberImages getNumberOfParameters getNumberOfRequiredParameters getNumericValue getNumFrames getOffset getOldContainer getOldValues getOperator  contained
syn keyword phpMethods  getOpt getOptDoc getOption getOptions getOutput getOutputBuffer getOutputHeaders getOwner getpackagename getPackageName getPackedSize getPage getPageLayout getPageMode getPanic getParam getParameter getParameters getParams getParent  contained
syn keyword phpMethods  getParentClass getParentMessage getParsedWords getParserProperty getPartsIterator getPath getPathInfo getPathname getPattern getPeer getPendingException getPerms getPersistentId getPharFlags getPID getPixelIterator getPixelRegionIterator getPoints getPointSize getPoolSize  contained
syn keyword phpMethods  getPort getPosition getPost getPostFields getPostFilename getPostFiles getPostfix getPrefix getPregFlags getPreparedParams getPrevious getPreviousIteratorRow getPrimaryLanguage getProfilingLevel getProperties getProperty getPropertyEnum getPropertyIndex getPropertyList getPropertyName  contained
syn keyword phpMethods  getPropertyNames getPropertyValueEnum getPropertyValueName getProtocolInformation getPrototype getPutData getPutFile getQuantum getquantumdepth getQuantumDepth getQuantumRange getQuery getQueryData getQurey getRawOffset getRawPostData getRawRequest getRawRequestHeaders getRawRequestMessage getRawResponse  contained
syn keyword phpMethods  getRawResponseHeaders getRawResponseMessage getReadPreference getReadTimeout getRealPath getRegex getRegion getRegistry getRelease getreleasedate getReleaseDate getRemovedStopwords getRepeatedWallTimeOption getRequest getRequestBody getRequestBodyStream getRequestHeader getRequestHeaders getRequestMessage getRequestMethod  contained
syn keyword phpMethods  getRequestToken getRequestUri getRequestUrl getResource getResourceLimit getResponse getResponseBody getResponseCode getResponseCookies getResponseData getResponseHeader getResponseInfo getResponseMessage getResponseStatus get_result getResultCode getResultMessage getReturn getReturnType getRgba  contained
syn keyword phpMethods  getRGBFill getRGBStroke getRootDataObject getRootElementName getRootElementURI getRot getRoute getRouter getRoutes getRows getRules getRuleStatus getRuleStatusVec getSampleBitrate getsamplingfactors getSamplingFactors getScaledFont getScaleMatrix getScript getScriptPath  contained
syn keyword phpMethods  getSecurityPrefs getSequence getServer getServerByKey getServerInformation getServerList getServers getServerStatistics getServerStatus getServerVersion getService getSessionId getSeverity getShape getShape1 getShape2 getShortName getSignature getsize getSize  contained
syn keyword phpMethods  getSizeOffset getSkippedWallTimeOption getSlave getSlaveOkay getSnapshot getSocket getSocketFd getSocketName getSocketType getSockOpt getSolrVersion getSortFields getSortKey getSource getSourceEncoding getSourceType getSqlstate getSslOptions getStacked getStandards  contained
syn keyword phpMethods  getStart getStartLine getStaticProperties getStaticPropertyValue getStaticVariables getStatistics getStats getStatsFacets getStatsFields getStatus getStatusString getStream getStreamSize getStrength getStride getStrokeAntialias getstrokecolor getStrokeColor getStrokeDashArray getStrokeDashOffset  contained
syn keyword phpMethods  getStrokeLineCap getStrokeLineJoin getStrokeMiterLimit getstrokeopacity getStrokeOpacity getstrokewidth getStrokeWidth getStrokingColorSpace getStub getSubIterator getSubPath getSubPathname getSubpixelOrder getSubstChars getSubType getSupportedCompression getSupportedMethods getSupportedSignatures getSurface getSvmType  contained
syn keyword phpMethods  getSvrProbability getSymbol getTagName getTags getTarget getTerminationInfo getTerms getTermsField getTermsIncludeLowerBound getTermsIncludeUpperBound getTermsLimit getTermsLowerBound getTermsMaxCount getTermsMinCount getTermsPrefix getTermsReturnRaw getTermsSort getTermsUpperBound getText getTextAlignment  contained
syn keyword phpMethods  getTextAntialias getTextAttribute gettextdecoration getTextDecoration gettextencoding getTextEncoding getTextInterlineSpacing getTextInterwordSpacing getTextKerning getTextLeading getTextMatrix getTextRenderingMode getTextRise getTextUnderColor getTextWidth getThis getThreadId getThrottleDelay getTime getTimeAllowed  contained
syn keyword phpMethods  getTimeOfDayCached getTimerTimeout getTimestamp getTimeType getTimezone getTimeZone getTimeZoneId getTitle getTolerance getToNeuron getTotalCount getTotalHits getTotalSize getTrace getTraceAsString getTrack getTraitAliases getTraitNames getTraits getTransitions  contained
syn keyword phpMethods  getTransMatrix getType getTypeName getTypeNamespaceURI __getTypes getTZDataVersion getUnicode getUnicodeVersion getUnicodeWidth getUnpackedSize getUpsertedCount getUpsertedIds getUri getUrl getURL getUTF8Width getValue getVectorGraphics getversion getVersion  contained
syn keyword phpMethods  getVersions getView getViewpath getWarningCount get_warnings getWeekendTransition getWeight getWidth getWordSpace getWriteConcern getWriteConcernError getWriteErrors getWriteResult getWritingMode getX getXHeight getXScale getXSkew getY getYear  contained
syn keyword phpMethods  getYScale getYSkew globally glyphExtents glyphPath gotExit gotStop group guessContentType haldClutImage handle has hasAttribute hasAttributeNS hasAttributes hasBinaryProperty hasChildNodes hasChildren hasConstant hasCurrentPoint  contained
syn keyword phpMethods  hasExsltSupport hasFeature hasFrame hash hasMetadata hasMethod hasNext hasnextimage hasNextImage hasPrev haspreviousimage hasPreviousImage hasProperty hasReturnType hasSameRules hasSiblings hasType head hint html  contained
syn keyword phpMethods  hwstat identify identifyFormat identifyImage identity identityMatrix idle immortal implementsInterface implodeimage implodeImage import importChar importFont importImagePixels importNode importStylesheet include increment incrementByKey  contained
syn keyword phpMethods  inDaylightTime inFill info init initIdentity initRotate initScale initTranslate initView inNamespace insert insertanchor insertBefore insertcollection insertData insertdocument insertPage inStroke interceptFileFuncs inTransaction  contained
syn keyword phpMethods  inverseFourierTransformImage invert invoke __invoke invokeArgs invokePending io is2LeggedEndpoint isAbstract isAbstractType isalnum isalpha isArbiter isArray isAsp isbase isblank isBoundary isBroken isBuffering  contained
syn keyword phpMethods  isBuiltin isCallable isCli isCloneable isClosure iscntrl isComment isCompressed isCompressedBZIP2 isCompressedGZ isConnected isConstructor isContainment isCopyrighted isCRCChecked isDataType isDead isDefault isDefaultNamespace isDefaultValueAvailable  contained
syn keyword phpMethods  isDefaultValueConstant isdefined isDeprecated isDestructor isdigit isDir isDirectory isDisabled isDispatched isDot isEmpty isEncrypted isEquivalentTo isExecutable isFile isFileFormat isFinal isGarbage isGenerator isGet  contained
syn keyword phpMethods  isgraph isHead isHidden isHtml isId isIDIgnorable isIDPart isIDStart isInstance isInstantiable isInterface isInternal isISOControl isIterateable isJavaIDPart isJavaIDStart isJavaSpaceChar isJoined isJste isKnown  contained
syn keyword phpMethods  isLenient isLink isLocalName isLogging islower isMany isMirrored isNick isNormalized isOpenType isOptional isOptions isOriginal isPassedByReference isPassive isPersistent isPhp isPixelSimilar isPixelSimilarQuantum isPost  contained
syn keyword phpMethods  isPrimary isprint isPristine isPrivate isProtected isProtectionEnabled isPublic ispunct isPut isReadable isRef isRequestTokenEndpoint isRouted isRunning isSameNode isSecondary isSequencedType __isset isSet isShutdown  contained
syn keyword phpMethods  isSimilar isSolid isspace isStarted isStatic isSubclassOf isSupported isSuspicious isTemporary isTerminated isText istitle isTrait isUAlphabetic isULowercase isupper isUserDefined isUsingExceptions isUUppercase isUWhiteSpace  contained
syn keyword phpMethods  isValid isValidPharFilename isVariadic isWaiting isWeekend isWhitespace isWhitespaceInElementContent isWorking isWritable isxdigit isXhtml isXml isXmlHttpRequest item iteration jobHandle jobStatus join jsonSerialize keepalive  contained
syn keyword phpMethods  key kill killConnection killCursor ksort labelFrame labelimage labelImage langdepvalue last lastEmpty lastError lastErrorCode lastErrorMsg lastInsertId lastInsertRowid lastInsertRowID leastSquaresByFactorisation leastSquaresBySVD levelimage  contained
syn keyword phpMethods  levelImage levelToString limit line linearStretchImage lineTo link liquidRescaleImage listAbbreviations listCollections listDBs listFields listIdentifiers listIDs listMethod listRegistry load loadExtension loadFile loadFromFile  contained
syn keyword phpMethods  loadFromString loadHosts loadHTML loadHTMLFile loadJPEG loadPhar loadPNG loadRaw loadString loadTTC loadTTF loadType1 loadXML localtime locateName lock lookup lookupNamespace lookupNamespaceURI lookupPrefix  contained
syn keyword phpMethods  loop loopCount loopFork loopInPoint loopOutPoint magnifyimage magnifyImage makeRequest mapimage mapImage mapPhar markDirty markDirtyRectangle mask maskSurface match matte matteFloodfillImage max maxTimeMS  contained
syn keyword phpMethods  measureText medianfilterimage medianFilterImage memoryUsage merge mergeImageLayers metaSearch Method mimetype minifyimage minifyImage mkdir mod modify modulateimage modulateImage montageImage more_results moreResults  contained
syn keyword phpMethods  morphImages morphology mosaicImages motionblurimage motionBlurImage mount move movePen movePenTo moveTextPos moveTo moveToAttribute moveToAttributeNo moveToAttributeNs moveToElement moveToFirstAttribute moveToNextAttribute moveToNextLine multColor multiply  contained
syn keyword phpMethods  multi_query mungServer natcasesort natsort negateImage newimage newImage newInstance newInstanceArgs newInstanceWithoutConstructor newPath newPixelIterator newPixelRegionIterator newPseudoImage newRowset newSubPath next Next nextElement nextEmpty  contained
syn keyword phpMethods  nextFrame nextimage nextImage next_result nextResult nextRowset noMultiple normalize normalizeDocument normalizeimage normalizeImage notify now nowUpdate num numColumns numFields numRows object  contained
syn keyword phpMethods  objectbyanchor offsetExists offsetGet offsetSet offsetUnset oilpaintimage oilPaintImage onClose onCreate opaquePaintImage open openFile openMemory openURI optimize optimizeImageLayers options ord orderedPosterizeImage out  contained
syn keyword phpMethods  output outputMemory paint paintFloodfillImage paintOpaqueImage paintTransparentImage paintWithAlpha parallelCollectionScan paramCount parents parse parseCurrency parseFile parseLocale parseMessage parseResolvConf parseString partial pathClose pathCurveToAbsolute  contained
syn keyword phpMethods  pathCurveToQuadraticBezierAbsolute pathCurveToQuadraticBezierRelative pathCurveToQuadraticBezierSmoothAbsolute pathCurveToQuadraticBezierSmoothRelative pathCurveToRelative pathCurveToSmoothAbsolute pathCurveToSmoothRelative pathEllipticArcAbsolute pathEllipticArcRelative pathExtents pathFinish pathLineToAbsolute pathLineToHorizontalAbsolute pathLineToHorizontalRelative pathLineToRelative pathLineToVerticalAbsolute pathLineToVerticalRelative pathMoveToAbsolute pathMoveToRelative pathStart  contained
syn keyword phpMethods  pconnect peek peekAll pending periodic pgsqlCopyFromArray pgsqlCopyFromFile pgsqlCopyToArray pgsqlCopyToFile pgsqlGetNotify pgsqlGetPid pgsqlLOBCreate pgsqlLOBOpen pgsqlLOBUnlink ping pingImage pingImageBlob pingImageFile point polaroidImage  contained
syn keyword phpMethods  poll polygon polyline poolDebug pop popClipPath popDefs popGroup popGroupToSource popPattern postDispatch posterizeImage preceding predict predict_probability preDispatch prepare prepend prependBody prependBuffer  contained
syn keyword phpMethods  prependByKey preResponse prev Prev prevEmpty prevError previewImages previous previousimage previousImage priorityInit profileimage profileImage pseudoInverse pullup push pushClipPath pushDefs pushGroup pushGroupWithContent  contained
syn keyword phpMethods  pushPattern put putCat putKeep putNr putShl quantizeimage quantizeImage quantizeimages quantizeImages query queryExec queryfontmetrics queryFontMetrics queryfonts queryFonts queryformats queryFormats queryPhrase queryReadResultsetHeader  contained
syn keyword phpMethods  querySingle quit quote radialblurimage radialBlurImage raiseimage raiseImage randomThresholdImage read readBuffer readFrame readFromStream readimage readImage readimageblob readImageBlob readimagefile readImageFile readImages readInnerXML  contained
syn keyword phpMethods  readLine readlock readonly readOuterXML readString readunlock real_connect real_escape_string real_query reap_async_query reapQuery reason reasonText receive recolorImage recommendedBackends recoverFromCorruption rectangle recv recvData  contained
syn keyword phpMethods  recvMulti redirect reducenoiseimage reduceNoiseImage refresh refreshServer register registerCallback registerExtension registerLocalNamespace registerNamespace registerNodeClass registerPhpFunctions registerPHPFunctions registerPlugin registerXPathNamespace reInit relaxNGValidate relaxNGValidateSource relCurveTo  contained
syn keyword phpMethods  release Release release_savepoint relLineTo relMoveTo remapImage remove removeAll removeAllExcept removeAttribute removeAttributeNode removeAttributeNS removeBigramPhraseField removeBoostQuery removeChild removeExpandFilterQuery removeExpandSortField removeFacetDateField removeFacetDateOther removeFacetField  contained
syn keyword phpMethods  removeFacetQuery removeField removeFilterQuery removeHeader removeHighlightField removeimage removeImage removeimageprofile removeImageProfile removeMltField removeMltQueryField removeOptions removeParameter removePhraseField removeQueryField removeRequiredParameter removeServerAlias removeSortField removeStatsFacet removeStatsField  contained
syn keyword phpMethods  removeTrigramPhraseField removeUserField rename renameIndex renameName render repair repairFile repairString replace replaceByKey replaceChild replaceData reportProblem request requireFeatures resampleimage resampleImage reset Reset  contained
syn keyword phpMethods  resetClip resetCookies resetError resetFilters resetGroupBy resetImagePage resetIterator resetLimit resetServerList resetStream resetValue resetVectorGraphics resize resizeimage resizeImage response restartPSession restore restrictToLevel restrictToVersion  contained
syn keyword phpMethods  result_metadata resume returnCode returnResponse returnsReference reverse rewind rmdir roll rollback rollBack rollimage rollImage root rotate rotateimage rotateImage rotateTo rotationalBlurImage roundCorners  contained
syn keyword phpMethods  roundrectangle roundRectangle route routerShutdown routerStartup rowCount rpl_query_type run running runQueries runTasks sampleImage save saveFile saveHTML saveHTMLFile savePicture savepoint saveString saveToFile  contained
syn keyword phpMethods  saveToStream saveToString saveVerbose saveXML scale scaleimage scaleImage scaleTo schemaValidate schemaValidateSource search searchEol seek seekResult segmentImage selectCollection select_db selectDb selectDB selectFontFace  contained
syn keyword phpMethods  selectiveBlurImage selectServer send sendClose sendComplete sendData sendError sendException sendFail send_long_data send_query sendQuery sendReply sendReplyChunk sendReplyEnd sendReplyStart sendStatus sendWarning sendWorkload separate  contained
syn keyword phpMethods  separateimagechannel separateImageChannel sepiaToneImage serialize serverDumpDebugInformation set __set setAccessible setAction setActionName setAlias setAllHeaders setAllowBroken setAllowedLocales setAllowedMethods setAntialias setAppDirectory setArchiveComment setArrayResult setAttribute  contained
syn keyword phpMethods  setAttributeNode setAttributeNodeNS setAttributeNS setAuthType setAutocommit setbackground setBackgroundColor setBaseUri setBigramPhraseFields setBigramPhraseSlop setBody setBoost setBoostFunction setBoostQuery setBorderStyle setBounds setBuffering setBufferSize setByKey setCache  contained
syn keyword phpMethods  setCacheControl setCalendar setCallback setCallbacks setCAPath set_charset setCharset setCharSpace setChecks setClass setClientCallback setClientOption setClipPath setClipRule setClipUnits setCloseCallback setCMYKFill setCMYKStroke setcolor setColor  contained
syn keyword phpMethods  setcolorcount setColorMask setColorspace setcolorvalue setColorValue setColorValueQuantum setCommentIndex setCommentName setcommittedversion setCompat setCompleteCallback setCompressedBZIP2 setCompressedGZ setCompression setCompressionIndex setCompressionMode setCompressionName setCompressionQuality setCompressThreshold setConnectTimeout  contained
syn keyword phpMethods  setContentDisposition setContentType setContext setControllerName __setCookie setCookies setCounterClass setCreatedCallback setCsvControl setCurrentEncoder setCurrentFont setDash setData setDataCallback setDate setDebug setDefault setDefaultAction setDefaultCallback setDefaultController  contained
syn keyword phpMethods  setDefaultModule setDefaultStub setDepth setDestination setDestinationEncoding setDeviceOffset setDimension setDispatched setDown setEchoHandler setEchoParams setEncoding setEncryptionMode setEps setErrorCallback setErrorHandler setETag setExceptionCallback setExpand setExpandQuery  contained
syn keyword phpMethods  setExpandRows setExplainOther setExtend setExternalAttributesIndex setExternalAttributesName setExtractFlags setFacet setFacetDateEnd setFacetDateGap setFacetDateHardEnd setFacetDateStart setFacetEnumCacheMinDefaultFrequency setFacetLimit setFacetMethod setFacetMinCount setFacetMissing setFacetOffset setFacetPrefix setFacetSort setFailCallback  contained
syn keyword phpMethods  setFallbackResolution setFetchMode setField setFieldBoost setFieldWeights setFile setFileClass setfilename setFilename setFillAlpha setfillcolor setFillColor setfillopacity setFillOpacity setFillPatternURL setFillRule setFilter setFilterFloatRange setFilterRange setFirstDayOfWeek  contained
syn keyword phpMethods  setFirstIterator setFit setFitB setFitBH setFitBV setFitH setFitR setFitV setFlag set_flags setFlags setFlatness setfont setFont setFontAndSize setFontFace setFontFamily setFontMatrix setFontOptions setfontsize  contained
syn keyword phpMethods  setFontSize setFontStretch setfontstyle setFontStyle setfontweight setFontWeight setFormat setFrames setGarbage setGeoAnchor setGravity setGrayFill setGrayStroke setGroup setGroupBy setGroupCachePercent setGroupDistinct setGroupFacet setGroupFormat setGroupLimit  contained
syn keyword phpMethods  setGroupMain setGroupNGroups setGroupOffset setGroupTruncate setGzip setHeader setHeaders setHeight setHighlight setHighlightAlternateField setHighlightFormatter setHighlightFragmenter setHighlightFragsize setHighlightHighlightMultiTerm setHighlightMaxAlternateFieldLength setHighlightMaxAnalyzedChars setHighlightMergeContiguous setHighlightMode setHighlightRegexMaxAnalyzedChars setHighlightRegexPattern  contained
syn keyword phpMethods  setHighlightRegexSlop setHighlightRequireFieldMatch setHighlightSimplePost setHighlightSimplePre setHighlightSnippets setHighlightUsePhraseHighlighter setHint setHintMetrics setHintStyle setHit setHorizontalScaling setHost setHSL setHttpVersion setIcon setId setIdAttribute setIdAttributeNode setIdAttributeNS setIdent  contained
syn keyword phpMethods  setIdleCallback setIdleTimeout setIDRange setImage setImageAlphaChannel setImageArtifact setImageAttribute setimagebackgroundcolor setImageBackgroundColor setImageBias setImageBiasQuantum setimageblueprimary setImageBluePrimary setimagebordercolor setImageBorderColor setimagechanneldepth setImageChannelDepth setImageClipMask setImageColormapColor setimagecolorspace  contained
syn keyword phpMethods  setImageColorspace setimagecompose setImageCompose setImageCompression setImageCompressionQuality setimagedelay setImageDelay setimagedepth setImageDepth setimagedispose setImageDispose setImageExtent setimagefilename setImageFilename setimageformat setImageFormat setimagegamma setImageGamma setImageGravity setimagegreenprimary  contained
syn keyword phpMethods  setImageGreenPrimary setimageindex setImageIndex setimageinterlacescheme setImageInterlaceScheme setImageInterpolateMethod setimageiterations setImageIterations setImageMatte setImageMatteColor setImageOpacity setImageOrientation setImagePage setimageprofile setImageProfile setImageProperty setimageredprimary setImageRedPrimary setimagerenderingintent setImageRenderingIntent  contained
syn keyword phpMethods  setimageresolution setImageResolution setimagescene setImageScene setImageTicksPerSecond setimagetype setImageType setimageunits setImageUnits setImageVirtualPixelMethod setimagewhitepoint setImageWhitePoint setIndent setIndentation setIndentString setIndex setIndexWeights setInfo setInfoAttr setInfoClass  contained
syn keyword phpMethods  setInfoDateAttr setInterlaceScheme setISODate setIteratorClass setIteratorFirstRow setIteratorIndex setIteratorLastRow setIteratorMode setIteratorRow setLastIterator setLastModified setLeftFill setLeftMargin setLenient setLevel setLibraryPath setLimit setLimits setLine setLineCap  contained
syn keyword phpMethods  setLineJoin setLineSpacing setLineWidth setLocalAddress set_local_infile_handler setLocalPort __setLocation setMargins setMaskImage setMaskLevel setMaster setMatchMode setMatrix setMax setMaxBodySize setMaxDepth setMaxDispatchInterval setMaxHeadersSize setMaxLineLen setMaxQueryTime  contained
syn keyword phpMethods  setMenu setMetadata setMethod setMimeType setMin setMinimalDaysInFirstWeek setMinimumMatch setMiterLimit setMlt setMltBoost setMltCount setMltMaxNumQueryTerms setMltMaxNumTokens setMltMaxWordLength setMltMinDocFrequency setMltMinTermFrequency setMltMinWordLength setMode setModule setModuleName  contained
syn keyword phpMethods  setMulti setMultiByKey setName setNonce setNullPolicy setObject setOmitHeader setOpenAction setOpened setOperator setOpt setOption setOptions setOrder setOver setOverride setPadding setPage setPageLayout setPageMode  contained
syn keyword phpMethods  setPagesConfiguration setParam setParameter setParseMode setParserProperty setPassword setPattern setPermission setPersistence setPhraseDelimiter setPhraseFields setPhraseSlop setPicture setPointSize setPoolSize setPort setPosition setPostFields setPostFilename setPostFiles  contained
syn keyword phpMethods  setPrefixPart setPregFlags setPriority setProfiling setProfilingLevel setProgressMonitor setPutData setPutFile setQuery setQueryAlt setQueryData setQueryPhraseSlop setRankingMode setRate setRatio setRawPostData setReadPreference setReadTimeout setRedirect setRegistry  contained
syn keyword phpMethods  setRelaxNGSchema setRelaxNGSchemaSource setRepeatedWallTimeOption setRequest setRequestEngine setRequestMethod setRequestTokenPath setRequestUri setRequestUrl setResolution setResourceLimit setResponseCode setResponseStatus setResponseWriter setRetries setReturn setRGBFill setRGBStroke setRightFill setRightMargin  contained
syn keyword phpMethods  setRotate setRouted setRows setRsaCertificate setRSACertificate setsamplingfactors setSamplingFactors setSaslAuthData setScaledFont setSchema setScriptPath setSearchNdots setSecret setSecurity setSecurityPrefs setSelect setServer setServerOption setServerParams setServlet  contained
syn keyword phpMethods  setShowDebugInfo setSignatureAlgorithm setsize setSize setSizeOffset setSkippedWallTimeOption setSlaveOkay setSlideShow __setSoapHeaders setSocketOption setSockOpt setSort setSortMode setSource setSourceEncoding setSourceRGB setSourceRGBA setSourceSurface setSpacing setSSLChecks  contained
syn keyword phpMethods  setSslOptions setStart __set_state setStaticPropertyValue setStats setStatusCallback setStream setStrength setStrokeAlpha setStrokeAntialias setstrokecolor setStrokeColor setStrokeDashArray setStrokeDashOffset setStrokeLineCap setStrokeLineJoin setStrokeMiterLimit setstrokeopacity setStrokeOpacity setStrokePatternURL  contained
syn keyword phpMethods  setstrokewidth setStrokeWidth setStructure setStub setSubpixelOrder setSubstChars setSymbol setTerms setTermsField setTermsIncludeLowerBound setTermsIncludeUpperBound setTermsLimit setTermsLowerBound setTermsMaxCount setTermsMinCount setTermsPrefix setTermsReturnRaw setTermsSort setTermsUpperBound setText  contained
syn keyword phpMethods  setTextAlignment setTextAntialias setTextAttribute settextdecoration setTextDecoration settextencoding setTextEncoding setTextInterlineSpacing setTextInterwordSpacing setTextKerning setTextLeading setTextMatrix setTextRenderingMode setTextRise setTextUnderColor setThrottleDelay setTieBreaker setTime setTimeAllowed setTimeout  contained
syn keyword phpMethods  setTimeouts setTimer setTimerCallback setTimerTimeout setTimestamp setTimezone setTimeZone setTimeZoneId setToken setTolerance setTrigramPhraseFields setTrigramPhraseSlop setType setTypeMap setUncompressed setUp setUrl setUserFields setUsingExceptions setValue  contained
syn keyword phpMethods  setVectorGraphics setVersion setView setViewbox setViewpath setWarningCallback setWatermark setWeight setWidth setWordSpace setWorkloadCallback setWriteConcern setXMLDeclaration setXMLVersion setXYZ shadeImage shadowImage sharpenImage shaveImage shearimage  contained
syn keyword phpMethods  shearImage shift showGlyphs showPage showText showTextNextLine shutdown shutdownServer sigmoidalContrastImage signal similarNames simpleCommand simpleCommandHandleResponse singleQuery singleton singularValues size sketchImage skewX skewXTo  contained
syn keyword phpMethods  skewY skewYTo skip slaveOkay sleep __sleep smushImages snapshot __soapCall SoapClient SoapFault SoapHeader SoapParam SoapServer SoapVar socketPerform socketSelect solarizeimage solarizeImage solveLinearEquation  contained
syn keyword phpMethods  sort sortWithSortKeys sparseColorImage spliceImage splitText spreadimage spreadImage sqliteCreateAggregate sqliteCreateCollation sqliteCreateFunction srcanchors srcsofdst sslError sslFilter sslGetCipherInfo sslGetCipherName sslGetCipherVersion sslGetProtocol sslRandPoll sslRenegotiate  contained
syn keyword phpMethods  ssl_set sslSet sslSocket stack start startAttribute startAttributeNS startBuffering startCData startComment startDocument startDTD startDTDAttlist startDTDElement startDTDEntity startElement startElementNS startPI startSound stat  contained
syn keyword phpMethods  statIndex statisticImage statName status statusToString steganoImage stem stereoImage stmt_init stmtInit stmt_send_long_data stop stopBuffering stopSound storeBytes storeFile store_result storeResult storeUpload stream_cast  contained
syn keyword phpMethods  stream_close stream_eof stream_flush stream_lock stream_metadata streamMP3 stream_open stream_read stream_seek stream_set_option stream_stat stream_tell stream_truncate stream_write strideForWidth stripimage stripImage stroke strokeExtents strokePreserve  contained
syn keyword phpMethods  sub subImageMatch submit submitTo subscribe substr substringData success supportedBackends suspend sweep swirlimage swirlImage switchSlave sync synchronized syncIterator system tailable taskDenominator  contained
syn keyword phpMethods  taskNumerator tell text textExtents textOut textPath textRect textureImage threads thresholdImage throw throwException thumbnailimage thumbnailImage time timeout timer timestampNonceHandler tintImage title  contained
syn keyword phpMethods  toArray toDateTime toDateTimeZone toIndexString tokenHandler tolower toMessageTypeObject top toString __toString totitle toUCallback touch touchByKey toupper train transcode transform transformDistance transformImage  contained
syn keyword phpMethods  transformImageColorspace transformPoint transformToDoc transformToURI transformToXML translate transliterate transparentPaintImage transposeImage transverseImage trim trimimage trimImage truncate trylock tune txCommit txRollback type uasort  contained
syn keyword phpMethods  uksort unbind unbufferedQuery unchangeAll unchangeArchive unchangeIndex unchangeName uncompressAllFiles unfreeze unique uniqueImageColors unlink unlinkArchive unlock unregister unregisterAll unserialize __unset unsharpMaskImage unshift  contained
syn keyword phpMethods  unstack unsubscribe update updateAttributes url_stat useCNSEncodings useCNSFonts useCNTEncodings useCNTFonts useDaylightTime useDisMaxQueryParser useEDisMaxQueryParser useJPEncodings useJPFonts useKREncodings useKRFonts user use_result useResult userlist  contained
syn keyword phpMethods  userToDevice userToDeviceDistance uuid valid validate value values vanish verify version versionString versionToString vignetteImage wait __wakeup walk warning waveImage webPhar whiteThresholdImage  contained
syn keyword phpMethods  work workload workloadSize write writeAttribute writeAttributeNS writeBuffer writeCData writeComment writeDTD writeDTDAttlist writeDTDElement writeDTDEntity writeElement writeElementNS writeExports writeimage writeImage writeImageFile writeImages  contained
syn keyword phpMethods  writeImagesFile writelock writePI writeRaw writeTemporary writeToPng writeunlock xinclude xlate xml xpath  contained

if exists( "php_baselib" )
  syn keyword phpMethods  query next_record num_rows affected_rows nf f p np num_fields haltmsg seek link_id query_id metadata table_names nextid connect halt free register unregister is_registered delete url purl self_url pself_url hidden_session add_query padd_query reimport_get_vars reimport_post_vars reimport_cookie_vars set_container set_tokenname release_token put_headers get_id get_id put_id freeze thaw gc reimport_any_vars start url purl login_if is_authenticated auth_preauth auth_loginform auth_validatelogin auth_refreshlogin auth_registerform auth_doregister start check have_perm permsum perm_invalid contained
  syn keyword phpFunctions  page_open page_close sess_load sess_save  contained
endif

" Conditional
syn keyword phpConditional  declare else enddeclare endswitch elseif endif if switch  contained

" Repeat
syn keyword phpRepeat as do endfor endforeach endwhile for foreach while  contained

" Repeat
syn keyword phpLabel  case default switch contained

" Statement
syn keyword phpStatement  return break continue exit goto  contained

" Keyword
syn keyword phpKeyword  var const contained

" Type
syn keyword phpType bool[ean] int[eger] real double float string array object NULL  contained

" Structure
syn keyword phpStructure  namespace extends implements instanceof parent self contained
syn match phpStructure "\<static\(\s\+\$\|::\)\@=" contained display

" Operator
syn match phpOperator "[-=+%^&|*!.~?:]" contained display
syn match phpOperator "[-+*/%^&|.]="  contained display
syn match phpOperator "/[^*/]"me=e-1  contained display
syn match phpOperator "\$"  contained display
syn match phpOperator "&&\|\<and\>" contained display
syn match phpOperator "||\|\<x\=or\>" contained display
syn match phpRelation "[!=<>]=" contained display
syn match phpRelation "[<>]"  contained display
syn match phpMemberSelector "->"  contained display
syn match phpVarSelector  "\$"  contained display

" Identifier
syn match phpIdentifier "$\h\w*"  contained contains=phpEnvVar,phpIntVar,phpVarSelector display
syn match phpIdentifierSimply "${\h\w*}"  contains=phpOperator,phpParent  contained display
syn region  phpIdentifierComplex  matchgroup=phpParent start="{\$"rs=e-1 end="}"  contains=phpIdentifier,phpMemberSelector,phpVarSelector,phpIdentifierComplexP contained extend
syn region  phpIdentifierComplexP matchgroup=phpParent start="\[" end="]" contains=@phpClInside contained

" Interpolated indentifiers (inside strings)
	syn match phpBrackets "[][}{]" contained display
	" errors
		syn match phpInterpSimpleError "\[[^]]*\]" contained display  " fallback (if nothing else matches)
		syn match phpInterpSimpleError "->[^a-zA-Z_]" contained display
		" make sure these stay above the correct DollarCurlies so they don't take priority
		syn match phpInterpBogusDollarCurley "${[^}]*}" contained display  " fallback (if nothing else matches)
	syn match phpinterpSimpleBracketsInner "\w\+" contained
	syn match phpInterpSimpleBrackets "\[\h\w*]" contained contains=phpBrackets,phpInterpSimpleBracketsInner
	syn match phpInterpSimpleBrackets "\[\d\+]" contained contains=phpBrackets,phpInterpSimpleBracketsInner
	syn match phpInterpSimpleBrackets "\[0[xX]\x\+]" contained contains=phpBrackets,phpInterpSimpleBracketsInner
	syn match phpInterpSimple "\$\h\w*\(\[[^]]*\]\|->\h\w*\)\?" contained contains=phpInterpSimpleBrackets,phpIdentifier,phpInterpSimpleError,phpMethods,phpMemberSelector display
	syn match phpInterpVarname "\h\w*" contained
	syn match phpInterpMethodName "\h\w*" contained " default color
	syn match phpInterpSimpleCurly "\${\h\w*}"  contains=phpInterpVarname contained extend
	syn region phpInterpDollarCurley1Helper matchgroup=phpParent start="{" end="\[" contains=phpInterpVarname contained
	syn region phpInterpDollarCurly1 matchgroup=phpParent start="\${\h\w*\["rs=s+1 end="]}" contains=phpInterpDollarCurley1Helper,@phpClConst contained extend

	syn match phpInterpDollarCurley2Helper "{\h\w*->" contains=phpBrackets,phpInterpVarname,phpMemberSelector contained

	syn region phpInterpDollarCurly2 matchgroup=phpParent start="\${\h\w*->"rs=s+1 end="}" contains=phpInterpDollarCurley2Helper,phpInterpMethodName contained

	syn match phpInterpBogusDollarCurley "${\h\w*->}" contained display
	syn match phpInterpBogusDollarCurley "${\h\w*\[]}" contained display

	syn region phpInterpComplex matchgroup=phpParent start="{\$"rs=e-1 end="}" contains=phpIdentifier,phpMemberSelector,phpVarSelector,phpIdentifierComplexP contained extend
	syn region phpIdentifierComplexP matchgroup=phpParent start="\[" end="]" contains=@phpClInside contained
	" define a cluster to get all interpolation syntaxes for double-quoted strings
	syn cluster phpInterpDouble contains=phpInterpSimple,phpInterpSimpleCurly,phpInterpDollarCurly1,phpInterpDollarCurly2,phpInterpBogusDollarCurley,phpInterpComplex

" Methoden
syn match phpMethodsVar "->\h\w*" contained contains=phpMethods,phpMemberSelector display

" Include
syn keyword phpInclude  include require include_once require_once use contained

" Peter Hodge - added 'clone' keyword
" Define
syn keyword phpDefine new clone contained

" Boolean
syn keyword phpBoolean  true false  contained

" Number
syn match phpNumber "-\=\<\d\+\>" contained display
syn match phpNumber "\<0x\x\{1,8}\>"  contained display

" Float
syn match phpFloat  "\(-\=\<\d+\|-\=\)\.\d\+\>" contained display

" Backslash escapes
	syn case match
	" for double quotes and heredoc
	syn match phpBackslashSequences  "\\[fnrtv\\\"$]" contained display
	syn match phpBackslashSequences  "\\\d\{1,3}"  contained contains=phpOctalError display
	syn match phpBackslashSequences  "\\x\x\{1,2}" contained display
	" additional sequence for double quotes only
	syn match phpBackslashDoubleQuote "\\[\"]" contained display
	" for single quotes only
	syn match phpBackslashSingleQuote "\\[\\']" contained display
	syn case ignore


" Error
syn match phpOctalError "[89]"  contained display
if exists("php_parent_error_close")
  syn match phpParentError  "[)\]}]"  contained display
endif

" Todo
syn keyword phpTodo todo fixme xxx  contained

" Comment
if exists("php_parent_error_open")
  syn region  phpComment  start="/\*" end="\*/" contained contains=phpTodo
else
  syn region  phpComment  start="/\*" end="\*/" contained contains=phpTodo extend
endif
if version >= 600
  syn match phpComment  "#.\{-}\(?>\|$\)\@="  contained contains=phpTodo
  syn match phpComment  "//.\{-}\(?>\|$\)\@=" contained contains=phpTodo
else
  syn match phpComment  "#.\{-}$" contained contains=phpTodo
  syn match phpComment  "#.\{-}?>"me=e-2  contained contains=phpTodo
  syn match phpComment  "//.\{-}$"  contained contains=phpTodo
  syn match phpComment  "//.\{-}?>"me=e-2 contained contains=phpTodo
endif

" String
if exists("php_parent_error_open")
  syn region  phpStringDouble matchgroup=None start=+"+ skip=+\\\\\|\\"+ end=+"+  contains=@phpAddStrings,phpBackslashSequences,phpBackslashDoubleQuote,@phpInterpDouble contained keepend
  syn region  phpBacktick matchgroup=None start=+`+ skip=+\\\\\|\\"+ end=+`+  contains=@phpAddStrings,phpIdentifier,phpBackslashSequences,phpIdentifierSimply,phpIdentifierComplex contained keepend
  syn region  phpStringSingle matchgroup=None start=+'+ skip=+\\\\\|\\'+ end=+'+  contains=@phpAddStrings,phpBackslashSingleQuote contained keepend
else
  syn region  phpStringDouble matchgroup=None start=+"+ skip=+\\\\\|\\"+ end=+"+  contains=@phpAddStrings,phpBackslashSequences,phpBackslashDoubleQuote,@phpInterpDouble contained extend keepend
  syn region  phpBacktick matchgroup=None start=+`+ skip=+\\\\\|\\"+ end=+`+  contains=@phpAddStrings,phpIdentifier,phpBackslashSequences,phpIdentifierSimply,phpIdentifierComplex contained extend keepend
  syn region  phpStringSingle matchgroup=None start=+'+ skip=+\\\\\|\\'+ end=+'+  contains=@phpAddStrings,phpBackslashSingleQuote contained keepend extend
endif

" HereDoc and NowDoc
if version >= 600
  syn case match

  " HereDoc
  syn region  phpHereDoc  matchgroup=Delimiter start="\(<<<\)\@<=\s*\(\"\=\)\z(\I\i*\)\2$" end="^\z1\(;\=$\)\@=" contained contains=phpIdentifier,phpIdentifierSimply,phpIdentifierComplex,phpBackslashSequences,phpMethodsVar keepend extend
" including HTML,JavaScript,SQL even if not enabled via options
  syn region  phpHereDoc  matchgroup=Delimiter start="\(<<<\)\@<=\s*\(\"\=\)\z(\(\I\i*\)\=\(html\)\c\(\i*\)\)\2$" end="^\z1\(;\=$\)\@="  contained contains=@htmlTop,phpIdentifier,phpIdentifierSimply,phpIdentifierComplex,phpBackslashSequences,phpMethodsVar keepend extend
  syn region  phpHereDoc  matchgroup=Delimiter start="\(<<<\)\@<=\s*\(\"\=\)\z(\(\I\i*\)\=\(sql\)\c\(\i*\)\)\2$" end="^\z1\(;\=$\)\@=" contained contains=@sqlTop,phpIdentifier,phpIdentifierSimply,phpIdentifierComplex,phpBackslashSequences,phpMethodsVar keepend extend
  syn region  phpHereDoc  matchgroup=Delimiter start="\(<<<\)\@<=\s*\(\"\=\)\z(\(\I\i*\)\=\(javascript\)\c\(\i*\)\)\2$" end="^\z1\(;\=$\)\@="  contained contains=@htmlJavascript,phpIdentifierSimply,phpIdentifier,phpIdentifierComplex,phpBackslashSequences,phpMethodsVar keepend extend

  " NowDoc
  syn region  phpNowDoc  matchgroup=Delimiter start="\(<<<\)\@<=\s*'\z(\I\i*\)'$" end="^\z1\(;\=$\)\@=" contained keepend extend
" including HTML,JavaScript,SQL even if not enabled via options
  syn region  phpNowDoc  matchgroup=Delimiter start="\(<<<\)\@<=\s*'\z(\(\I\i*\)\=\(html\)\c\(\i*\)\)'$" end="^\z1\(;\=$\)\@="  contained contains=@htmlTop keepend extend
  syn region  phpNowDoc  matchgroup=Delimiter start="\(<<<\)\@<=\s*'\z(\(\I\i*\)\=\(sql\)\c\(\i*\)\)'$" end="^\z1\(;\=$\)\@=" contained contains=@sqlTop keepend extend
  syn region  phpNowDoc  matchgroup=Delimiter start="\(<<<\)\@<=\s*'\z(\(\I\i*\)\=\(javascript\)\c\(\i*\)\)'$" end="^\z1\(;\=$\)\@="  contained contains=@htmlJavascript keepend extend
  syn case ignore
endif

" Parent
if exists("php_parent_error_close") || exists("php_parent_error_open")
  syn match phpParent "[{}]"  contained
  syn region  phpParent matchgroup=Delimiter start="(" end=")"  contained contains=@phpClInside,phpDefine transparent
  syn region  phpParent matchgroup=Delimiter start="\[" end="\]"  contained contains=@phpClInside transparent
  if !exists("php_parent_error_close")
    syn match phpParent "[\])]" contained
  endif
else
  syn match phpParent "[({[\]})]" contained
endif

syn cluster phpClConst  contains=phpFunctions,phpIdentifier,phpConditional,phpRepeat,phpStatement,phpOperator,phpRelation,phpStringSingle,phpStringDouble,phpBacktick,phpNumber,phpFloat,phpKeyword,phpType,phpBoolean,phpStructure,phpMethodsVar,phpConstant,phpCoreConstant,phpException
syn cluster phpClInside contains=@phpClConst,phpComment,phpLabel,phpParent,phpParentError,phpInclude,phpHereDoc,phpNowDoc
syn cluster phpClFunction contains=@phpClInside,phpDefine,phpParentError,phpStorageClass
syn cluster phpClException contains=phpFoldTry,phpFoldCatch,phpFoldFinally,phpException
syn cluster phpClTop  contains=@phpClFunction,phpFoldFunction,phpFoldClass,phpFoldInterface,phpFoldTrait,phpFoldTry,phpFoldCatch,phpFoldFinally

" Php Region
if exists("php_parent_error_open")
  if exists("php_noShortTags")
    syn region   phpRegion  matchgroup=Delimiter start="<?php" end="?>" contains=@phpClTop
  else
    syn region   phpRegion  matchgroup=Delimiter start="<?\(php\)\=" end="?>" contains=@phpClTop
  endif
  syn region   phpRegionSc  matchgroup=Delimiter start=+<script language="php">+ end=+</script>+  contains=@phpClTop
  if exists("php_asp_tags")
    syn region   phpRegionAsp matchgroup=Delimiter start="<%\(=\)\=" end="%>" contains=@phpClTop
  endif
else
  if exists("php_noShortTags")
    syn region   phpRegion  matchgroup=Delimiter start="<?php" end="?>" contains=@phpClTop keepend
  else
    syn region   phpRegion  matchgroup=Delimiter start="<?\(php\)\=" end="?>" contains=@phpClTop keepend
  endif
  syn region   phpRegionSc  matchgroup=Delimiter start=+<script language="php">+ end=+</script>+  contains=@phpClTop keepend
  if exists("php_asp_tags")
    syn region   phpRegionAsp matchgroup=Delimiter start="<%\(=\)\=" end="%>" contains=@phpClTop keepend
  endif
endif

" Fold
if exists("php_folding") && php_folding==1


" match one line constructs here and skip them at folding
  syn keyword phpSCKeyword  abstract final private protected public static  contained
  syn keyword phpFCKeyword  function  contained
  syn keyword phpStorageClass global  contained
  syn keyword phpException  throw contained
  "syn keyword phpException  catch throw try finally contained
  syn match phpDefine "\(\s\|^\)\(abstract\s\+\|final\s\+\|private\s\+\|protected\s\+\|public\s\+\|static\s\+\)*function\(\s\+.*[;}]\)\@="  contained contains=phpSCKeyword
  syn match phpStructure  "\(\s\|^\)\(abstract\s\+\|final\s\+\)*class\(\s\+.*}\)\@="  contained
  syn match phpStructure  "\(\s\|^\)interface\(\s\+.*}\)\@="  contained
  syn match phpStructure  "\(\s\|^\)trait\(\s\+.*}\)\@="  contained
  syn match phpException  "\(\s\|^\)try\(\s\+.*}\)\@="  contained
  syn match phpException  "\(\s\|^\)catch\(\s\+.*}\)\@="  contained
  syn match phpException  "\(\s\|^\)finally\(\s\+.*}\)\@="  contained

  " We only fold on certain conditions (try(.*{)\@! and ^\s*(catch|finally)) so take
  " care of the other possibilities
  syn match phpException  "\(^\s*}\s\)\@<=\(catch\|finally\)\>"  contained
  syn match phpException  "^\s*try\>\(\s{\)\@="  contained

  set foldmethod=syntax
  syn region  phpFoldHtmlInside matchgroup=Delimiter start="?>" end="<?\(php\)\=" contained transparent contains=@htmlTop

  " methods and functions
  " use a trick here to simplify the pattern and to be able to use a
  " background color.
  " use the Storageclass match group and rs=e-9 to make the region start
  " before 'function ' so that function can have the proper color
  syn region  phpFoldFunction matchgroup=Storageclass start="^\z(\s*\)\(abstract\s\+\|final\s\+\|private\s\+\|protected\s\+\|public\s\+\|static\s\+\)*function\s\([^};]*$\)\@="rs=e-9 matchgroup=Delimiter end="^\z1}" contains=@phpClFunction,@phpClException,phpFoldHtmlInside,phpFCKeyword contained transparent fold extend

   " Unfortunately the rs=e-9 makes the highlight fail when 'function' is at col 0
  syn region  phpFoldFunction matchgroup=Define start="^function\(\s[^};]*$\)\@=" matchgroup=Delimiter end="^}" contains=@phpClFunction,@phpClException,phpFoldHtmlInside,phpFCKeyword contained transparent fold extend

  " interfaces, trait and classes
  syn region  phpFoldInterface  matchgroup=Structure start="^\z(\s*\)interface\s\+\([^}]*$\)\@=" matchgroup=Delimiter end="^\z1}" contains=@phpClFunction,phpFoldFunction contained transparent fold extend
  syn region  phpFoldTrait  matchgroup=Structure start="^\z(\s*\)trait\s\+\([^}]*$\)\@=" matchgroup=Delimiter end="^\z1}" contains=@phpClFunction,phpFoldFunction contained transparent fold extend
  syn region  phpFoldClass  matchgroup=Structure start="^\z(\s*\)\(abstract\s\+\|final\s\+\)*class\s\+\([^}]*$\)\@=" matchgroup=Delimiter end="^\z1}" contains=@phpClFunction,phpFoldFunction,phpSCKeyword contained transparent extend

  "Exceptions
  syn region  phpFoldTry  matchgroup=Exception start="^\z(\s*\)try\(.*{\)\@!" matchgroup=Delimiter end="^\z1}" contains=@phpClInside,@phpClException,phpDefine contained transparent fold extend
  syn region  phpFoldCatch  matchgroup=Exception start="^\z(\s*\)catch\s\+\([^}]*$\)\@=" matchgroup=Delimiter end="^\z1}" contains=@phpClInside,@phpClException,phpDefine contained transparent fold extend
  syn region  phpFoldFinally  matchgroup=Exception start="^\z(\s*\)finally\s\+\([^}]*$\)\@=" matchgroup=Delimiter end="^\z1}" contains=@phpClInside,@phpClException,phpDefine contained transparent fold extend


elseif exists("php_folding") && php_folding==2
  syn keyword phpDefine function  contained
  syn keyword phpStructure  abstract class interface trait contained
  syn keyword phpException  catch throw try finally contained
  syn keyword phpStorageClass final global private protected public static  contained

  set foldmethod=syntax
  syn region  phpFoldHtmlInside matchgroup=Delimiter start="?>" end="<?\(php\)\=" contained transparent contains=@htmlTop
  syn region  phpParent matchgroup=Delimiter start="{" end="}"  contained contains=@phpClFunction,phpFoldHtmlInside transparent fold
else
  syn keyword phpDefine function  contained
  syn keyword phpStructure  abstract class interface trait contained
  syn keyword phpException  catch throw try finally contained
  syn keyword phpStorageClass final global private protected public static  contained
endif

" ================================================================
" Peter Hodge - June 9, 2006
" Some of these changes (highlighting isset/unset/echo etc) are not so
" critical, but they make things more colourful. :-)

" different syntax highlighting for 'echo', 'print', 'switch', 'die' and 'list' keywords
" to better indicate what they are.
syntax keyword phpDefine echo print contained
syntax keyword phpStructure list contained
syntax keyword phpConditional switch contained
syntax keyword phpStatement die contained

" Highlighting for PHP5's user-definable magic class methods
syntax keyword phpSpecialFunction containedin=ALLBUT,phpComment,phpStringDouble,phpStringSingle,phpIdentifier
  \ __construct __destruct __call __toString __sleep __wakeup __set __get __unset __isset __clone __set_state
" Highlighting for __autoload slightly different from line above
syntax keyword phpSpecialFunction containedin=ALLBUT,phpComment,phpStringDouble,phpStringSingle,phpIdentifier,phpMethodsVar
  \ __autoload
highlight link phpSpecialFunction phpOperator

" Highlighting for PHP5's built-in classes
" - built-in classes harvested from get_declared_classes() in 5.6.16
syntax keyword phpClasses containedin=ALLBUT,phpComment,phpStringDouble,phpStringSingle,phpIdentifier,phpMethodsVar
  \ stdClass Exception ErrorException Closure Generator DateTime 
  \ DateTimeImmutable DateTimeZone DateInterval DatePeriod LibXMLError DOMException 
  \ DOMStringList DOMNameList DOMImplementationList DOMImplementationSource DOMImplementation DOMNode 
  \ DOMNameSpaceNode DOMDocumentFragment DOMDocument DOMNodeList DOMNamedNodeMap DOMCharacterData 
  \ DOMAttr DOMElement DOMText DOMComment DOMTypeinfo DOMUserDataHandler 
  \ DOMDomError DOMErrorHandler DOMLocator DOMConfiguration DOMCdataSection DOMDocumentType 
  \ DOMNotation DOMEntity DOMEntityReference DOMProcessingInstruction DOMStringExtend DOMXPath 
  \ finfo LogicException BadFunctionCallException BadMethodCallException DomainException InvalidArgumentException 
  \ LengthException OutOfRangeException RuntimeException OutOfBoundsException OverflowException RangeException 
  \ UnderflowException UnexpectedValueException RecursiveIteratorIterator IteratorIterator FilterIterator RecursiveFilterIterator 
  \ CallbackFilterIterator RecursiveCallbackFilterIterator ParentIterator LimitIterator CachingIterator RecursiveCachingIterator 
  \ NoRewindIterator AppendIterator InfiniteIterator RegexIterator RecursiveRegexIterator EmptyIterator 
  \ RecursiveTreeIterator ArrayObject ArrayIterator RecursiveArrayIterator SplFileInfo DirectoryIterator 
  \ FilesystemIterator RecursiveDirectoryIterator GlobIterator SplFileObject SplTempFileObject SplDoublyLinkedList 
  \ SplQueue SplStack SplHeap SplMinHeap SplMaxHeap SplPriorityQueue 
  \ SplFixedArray SplObjectStorage MultipleIterator PDOException PDO PDOStatement 
  \ PDORow ReflectionException Reflection ReflectionFunctionAbstract ReflectionFunction ReflectionParameter 
  \ ReflectionMethod ReflectionClass ReflectionObject ReflectionProperty ReflectionExtension ReflectionZendExtension 
  \ SessionHandler SimpleXMLElement SimpleXMLIterator __PHP_Incomplete_Class php_user_filter Directory 
  \ XMLReader XMLWriter CURLFile
highlight link phpClasses phpFunctions

" Highlighting for PHP5's built-in interfaces
" - built-in classes harvested from get_declared_interfaces() in 5.1.4
syntax keyword phpInterfaces containedin=ALLBUT,phpComment,phpStringDouble,phpStringSingle,phpIdentifier,phpMethodsVar
  \ Traversable IteratorAggregate Iterator ArrayAccess Serializable DateTimeInterface 
  \ JsonSerializable RecursiveIterator OuterIterator Countable SeekableIterator SplObserver 
  \ SplSubject Reflector SessionHandlerInterface SessionIdInterface
highlight link phpInterfaces phpConstant

" option defaults:
if ! exists('php_special_functions')
    let g:php_special_functions = 1
endif
if ! exists('php_alt_comparisons')
    let g:php_alt_comparisons = 1
endif
if ! exists('php_alt_assignByReference')
    let g:php_alt_assignByReference = 1
endif

if php_special_functions
    " Highlighting for PHP built-in functions which exhibit special behaviours
    " - isset()/unset()/empty() are not real functions.
    " - compact()/extract() directly manipulate variables in the local scope where
    "   regular functions would not be able to.
    " - eval() is the token 'make_your_code_twice_as_complex()' function for PHP.
    " - user_error()/trigger_error() can be overloaded by set_error_handler and also
    "   have the capacity to terminate your script when type is E_USER_ERROR.
    syntax keyword phpSpecialFunction containedin=ALLBUT,phpComment,phpStringDouble,phpStringSingle
  \ user_error trigger_error isset unset eval extract compact empty
endif

if php_alt_assignByReference
    " special highlighting for '=&' operator
    syntax match phpAssignByRef /=\s*&/ containedin=ALLBUT,phpComment,phpStringDouble,phpStringSingle
    highlight link phpAssignByRef Type
endif

if php_alt_comparisons
  " highlight comparison operators differently
  syntax match phpComparison "\v[=!]\=\=?" contained containedin=phpRegion
  syntax match phpComparison "\v[=<>-]@<![<>]\=?[<>]@!" contained containedin=phpRegion

  " highlight the 'instanceof' operator as a comparison operator rather than a structure
  syntax case ignore
  syntax keyword phpComparison instanceof contained containedin=phpRegion

  hi link phpComparison Statement
endif

" ================================================================

" Sync
if php_sync_method==-1
  if exists("php_noShortTags")
    syn sync match phpRegionSync grouphere phpRegion "^\s*<?php\s*$"
  else
    syn sync match phpRegionSync grouphere phpRegion "^\s*<?\(php\)\=\s*$"
  endif
  syn sync match phpRegionSync grouphere phpRegionSc +^\s*<script language="php">\s*$+
  if exists("php_asp_tags")
    syn sync match phpRegionSync grouphere phpRegionAsp "^\s*<%\(=\)\=\s*$"
  endif
  syn sync match phpRegionSync grouphere NONE "^\s*?>\s*$"
  syn sync match phpRegionSync grouphere NONE "^\s*%>\s*$"
  syn sync match phpRegionSync grouphere phpRegion "function\s.*(.*\$"
  "syn sync match phpRegionSync grouphere NONE "/\i*>\s*$"
elseif php_sync_method>0
  exec "syn sync minlines=" . php_sync_method
else
  exec "syn sync fromstart"
endif

syntax match  phpDocCustomTags  "@[a-zA-Z]*\(\s\+\|\n\|\r\)" containedin=phpComment
syntax region phpDocTags  start="{@\(example\|id\|internal\|inheritdoc\|link\|source\|toc\|tutorial\)" end="}" containedin=phpComment
syntax match  phpDocTags  "@\(abstract\|access\|author\|category\|copyright\|deprecated\|example\|final\|global\|ignore\|internal\|license\|link\|method\|name\|package\|param\|property\|return\|see\|since\|static\|staticvar\|subpackage\|tutorial\|uses\|var\|version\|contributor\|modified\|filename\|description\|filesource\|throws\)\(\s\+\)\?" containedin=phpComment
syntax match  phpDocTodo  "@\(todo\|fixme\|xxx\)\(\s\+\)\?" containedin=phpComment

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_php_syn_inits")
  if version < 508
    let g:did_php_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink   phpConstant  Constant
  HiLink   phpCoreConstant  Constant
  HiLink   phpComment Comment
  HiLink   phpDocTags PreProc
  HiLink   phpDocCustomTags Type
  HiLink   phpException Exception
  HiLink   phpBoolean Boolean
  HiLink   phpStorageClass  StorageClass
  HiLink   phpSCKeyword StorageClass
  HiLink   phpFCKeyword Define
  HiLink   phpStructure Structure
  HiLink   phpStringSingle  String
  HiLink   phpStringDouble  String
  HiLink   phpBacktick  String
  HiLink   phpNumber  Number
  HiLink   phpFloat Float
  HiLink   phpMethods Function
  HiLink   phpFunctions Function
  HiLink   phpBaselib Function
  HiLink   phpRepeat  Repeat
  HiLink   phpConditional Conditional
  HiLink   phpLabel Label
  HiLink   phpStatement Statement
  HiLink   phpKeyword Statement
  HiLink   phpType  Type
  HiLink   phpInclude Include
  HiLink   phpDefine  Define
  HiLink   phpBackslashSequences SpecialChar
  HiLink   phpBackslashDoubleQuote SpecialChar
  HiLink   phpBackslashSingleQuote SpecialChar
  HiLink   phpParent  Delimiter
  HiLink   phpBrackets  Delimiter
  HiLink   phpIdentifierConst Delimiter
  HiLink   phpParentError Error
  HiLink   phpOctalError  Error
  HiLink   phpInterpSimpleError Error
  HiLink   phpInterpBogusDollarCurley Error
  HiLink   phpInterpDollarCurly1 Error
  HiLink   phpInterpDollarCurly2 Error
  HiLink   phpInterpSimpleBracketsInner String
  HiLink   phpInterpSimpleCurly Delimiter
  HiLink   phpInterpVarname Identifier
  HiLink   phpTodo  Todo
  HiLink   phpDocTodo Todo
  HiLink   phpMemberSelector  Structure
  if exists("php_oldStyle")
  hi  phpIntVar guifg=Red ctermfg=DarkRed
  hi  phpEnvVar guifg=Red ctermfg=DarkRed
  hi  phpOperator guifg=SeaGreen ctermfg=DarkGreen
  hi  phpVarSelector guifg=SeaGreen ctermfg=DarkGreen
  hi  phpRelation guifg=SeaGreen ctermfg=DarkGreen
  hi  phpIdentifier guifg=DarkGray ctermfg=Brown
  hi  phpIdentifierSimply guifg=DarkGray ctermfg=Brown
  else
  HiLink   phpIntVar Identifier
  HiLink   phpEnvVar Identifier
  HiLink   phpOperator Operator
  HiLink   phpVarSelector  Operator
  HiLink   phpRelation Operator
  HiLink   phpIdentifier Identifier
  HiLink   phpIdentifierSimply Identifier
  endif

  delcommand HiLink
endif

let b:current_syntax = "php"

if main_syntax == 'php'
  unlet g:main_syntax
endif

" put cpoptions back the way we found it
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sts=2 sw=2 expandtab
