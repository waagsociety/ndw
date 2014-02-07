pwd = File.expand_path File.dirname(__FILE__)
SQL = <<-SQL
  -- Create table
  CREATE TABLE vild (
    LOC_NR int,
    LOC_TYPE text,
    LOC_DES text,
    ROADNUMBER text,
    ROADNAME text,
    FIRST_NAME text,
    SECND_NAME text,
    JUNCT_REF int,
    EXIT_NR text,
    HSTART_POS int,
    HEND_POS int,
    HSTART_NEG int,
    HEND_NEG int,
    HECTO_CHAR text,
    HECTO_DIR int,
    POS_IN int,
    POS_OUT int,
    NEG_IN int,
    NEG_OUT int,
    DIR text,
    AREA_REF int,
    LIN_REF int,
    INTER_REF int,
    POS_OFF int,
    NEG_OFF int,
    URBAN_CODE int,
    PRES_POS int,
    PRES_NEG int,
    FAR_AWAY int,
    CITY_DISTR text,
    TOP_SIGN text,
    TYPE_CODE int,
    MW_REF int,
    RW_NR int,
    AW_RE int
  );

  -- Import CSV file
  COPY vild FROM '#{pwd}/vild/vild.csv' DELIMITERS ',' CSV HEADER;
SQL

puts SQL