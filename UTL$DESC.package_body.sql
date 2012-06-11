CREATE OR REPLACE
PACKAGE BODY UTL$DESC
IS
    /**
    * ============================================================================
    *                           History of changes
    * ============================================================================
    *  Date (DD/MM/YYYY) Who               Description
    * ----------------- ----------------- --------------------------------
    *  11/06/2012        Martin Mareš      GitHub distribution
    * ============================================================================
    */

    /**
    * ----------------------------------------------------------------------
    * Local functions
    * ----------------------------------------------------------------------
    */
    FUNCTION normalize_data_type(data_type_in      IN T_SMALL_STRING
                                ,data_length_in    IN T_SMALL_INTEGER
                                ,data_precision_in IN T_SMALL_INTEGER
                                ,data_scale_in     IN T_SMALL_INTEGER
                                ,nullable_in       IN T_DB_BOOLEAN
                                ,data_default_in   IN T_LONG_STRING) RETURN T_SMALL_STRING
    IS
        l_return VARCHAR2(1024) := NULL;

    BEGIN
        CASE
            WHEN data_type_in = 'CHAR' THEN
                l_return := data_type_in ||
                            '(' ||
                            data_length_in ||
                            ')';
            WHEN data_type_in = 'DATE' THEN
                l_return := data_type_in;
            WHEN data_type_in = 'FLOAT'
                 AND data_scale_in IS NOT NULL THEN
                l_return := data_type_in ||
                            '(' ||
                            data_precision_in ||
                            ',' ||
                            data_scale_in ||
                            ')';
            WHEN data_type_in = 'FLOAT' THEN
                l_return := data_type_in ||
                            '(' ||
                            data_precision_in ||
                            ')';
            WHEN data_type_in = 'LONG' THEN
                l_return := data_type_in;
            WHEN data_type_in = 'NUMBER'
                 AND data_precision_in IS NOT NULL
                 AND data_scale_in IS NOT NULL THEN
                l_return := data_type_in ||
                            '(' ||
                            data_precision_in ||
                            ',' ||
                            data_scale_in ||
                            ')';
            WHEN data_type_in = 'NUMBER'
                 AND data_precision_in IS NOT NULL
                 AND data_scale_in IS NULL THEN
                l_return := data_type_in ||
                            '(' ||
                            data_precision_in ||
                            ')';
            WHEN data_type_in = 'NUMBER' THEN
                l_return := data_type_in;
            WHEN data_type_in = 'VARCHAR' THEN
                l_return := data_type_in ||
                            '(' ||
                            data_length_in ||
                            ')';
            WHEN data_type_in = 'VARCHAR2' THEN
                l_return := data_type_in ||
                            '(' ||
                            data_length_in ||
                            ')';
        ELSE
            l_return := data_type_in;
        END CASE;

        IF (data_default_in IS NOT NULL) THEN
            l_return := l_return ||
                        ' DEFAULT ' ||
                        data_default_in;
        END IF;

        IF (nullable_in IS NOT NULL
            AND nullable_in = 'N') THEN
            l_return := l_return ||
                        ' NOT NULL';
        END IF;

        RETURN l_return;
    END normalize_data_type;

    /**
    * ----------------------------------------------------------------------
    * User objects
    * ----------------------------------------------------------------------
    */

    PROCEDURE prn(string_in IN T_MAX_STRING)
    IS

    BEGIN
        NULL;
    END prn;

    FUNCTION desc_table(table_name_in IN T_SMALL_STRING) RETURN T_MAX_STRING
    IS

    BEGIN
        RETURN desc_table(owner_in => USER, table_name_in => table_name_in, output_format_in => C_FORMAT_DEFAULT);
    END desc_table;

    FUNCTION desc_table(owner_in      IN T_SMALL_STRING
                       ,table_name_in IN T_SMALL_STRING) RETURN T_MAX_STRING
    IS

    BEGIN
        RETURN desc_table(owner_in => owner_in, table_name_in => table_name_in, output_format_in => C_FORMAT_DEFAULT);
    END desc_table;

    FUNCTION desc_table(owner_in         IN T_SMALL_STRING
                       ,table_name_in    IN T_SMALL_STRING
                       ,output_format_in IN T_SMALL_STRING) RETURN T_MAX_STRING
    IS
        l_return   T_MAX_STRING;
        l_obj_cnt  T_PLS_INTEGER;
        l_tbl_cols LST_TABLE_COLUMNS;

    BEGIN

        SELECT COUNT(1)
          INTO l_obj_cnt
          FROM user_tables tab
         WHERE tab.TABLE_NAME = table_name_in;

        IF (l_obj_cnt > 0) THEN
            l_tbl_cols.DELETE;

            <<list_columns>>
            FOR rec_col IN  (SELECT col.COLUMN_NAME
                                   ,col.DATA_TYPE
                                   ,col.DATA_LENGTH
                                   ,col.DATA_PRECISION
                                   ,col.DATA_SCALE
                                   ,col.NULLABLE
                                   ,col.DATA_DEFAULT
                               FROM user_tab_columns col
                              WHERE col.TABLE_NAME = table_name_in ) LOOP
                l_tbl_cols(l_tbl_cols.COUNT).DATA_TYPE := rec_col.DATA_TYPE;
                l_tbl_cols(l_tbl_cols.LAST).DATA_LENGTH := rec_col.DATA_LENGTH;
                l_tbl_cols(l_tbl_cols.LAST).DATA_PRECISION := rec_col.DATA_PRECISION;
                l_tbl_cols(l_tbl_cols.LAST).DATA_SCALE := rec_col.DATA_SCALE;
                l_tbl_cols(l_tbl_cols.LAST).NULLABLE := rec_col.NULLABLE;
                l_tbl_cols(l_tbl_cols.LAST).DATA_DEFAULT := rec_col.DATA_DEFAULT;
            END LOOP list_columns;

        END IF;

        RETURN l_return;
    END desc_table;

END UTL$DESC;
/
