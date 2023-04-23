%let pgm=utl-stack-datasets-where-variable-is-character-in-one-dataset-and-numeric-in-another;

Stack datasets where variable is character in one dataset and numeric in another and maintain variable names

I don't think it is a good idea to solve this problem without some manual intervention.

Suppose Age is numeric in the first dataset but character in the next.

     Sample Values  (know thy data)
         Age  14   numeric   in dataset 1
         Age  '<1' character in dataset 2

     If we convert the numeric to character you don't lose '< 1'
     However if we convert age in dataset 2 to numeric we lose '<1' it becomes missing,


For this solution I assume that if a variable has both numeric and character type, the correct type is numeric.

https://tinyurl.com/ycyh7ra4
SAS: How to vertically join multiple datasets where a variable is numeric in one dataset and character in the other
https://stackoverflow.com/questions/75238694/sas-how-to-vertically-join-multiple-datasets-where-a-variable-is-numeric-in-one

/*
(_)___ ___ _   _  ___
| / __/ __| | | |/ _ \
| \__ \__ \ |_| |  __/
|_|___/___/\__,_|\___|

*/

46    data want;
ERROR: Variable AGE has been defined as both character and numeric.
ERROR: Variable AGE has been defined as both character and numeric.
47        set
48         mix.havone
49         mix.havtwo
50         mix.havtre
51        ;
52    run;


/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/


/*----                     ----*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  Directory into clipboard                                                                                              */
/*  x 'tree "d:/mix" /F /A | clip'                                                                                        */
/*                                                                                                                        */
/*  We will load these datasets into manually created f:/mix folder                                                       */
/*                                                                                                                        */
/*   D:\MIX                                                                                                               */
/*                                                                                                                        */
/*      havone.sas7bdat                                                                                                   */
/*      havtwo.sas7bdat                                                                                                   */
/*      havtre.sas7bdat                                                                                                   */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*----    manuall create d:/mix folder                      ----*/
libname mix "d:/mix";

/*----    numeric age                                       ----*/
data mix.havOne;
  set sashelp.classfit(obs=3 keep=name sex age);
run;quit;

/*----    incorrect character age                           ----*/
data mix.havTwo;
  set sashelp.classfit(obs=3 keep=name sex weight);
  age=put(int(200*uniform(4321)),4.);
run;quit;

/*----    incorrect character age                           ----*/
data mix.havTre;
  set sashelp.classfit(obs=3 keep=name sex);
  age=put(int(200*uniform(4321)),4.);
run;quit;

 /**************************************************************************************************************************/
 /*                                                                                                                        */
 /*           HavOne          HavTwo              HavTre                                                                   */
 /*                                                                                                                        */
 /*      ================   ================   ==============                                                              */
 /* #    Variable  Type     Variable  Type      Variable  Type                                                             */
 /*                                                                                                                        */
 /* 1    NAME      Char     NAME      Char      NAME      Char                                                             */
 /* 2    SEX       Char     SEX       Char      SEX       Char                                                             */
 /* 3    AGE       Num      AGE       Char**    AGE       Char**                                                           */
 /*                         WEIGHT    Num                                                                                  */
 /* ** Wrong type                                                                                                          */
 /*                                                                                                                        */
 /**************************************************************************************************************************/
/*
 ___  __ _ ___   _ __  _ __ ___   ___ ___  ___ ___
/ __|/ _` / __| | `_ \| `__/ _ \ / __/ _ \/ __/ __|
\__ \ (_| \__ \ | |_) | | | (_) | (_|  __/\__ \__ \
|___/\__,_|___/ | .__/|_|  \___/ \___\___||___/___/
                |_|
*/

/*---- variables with mixed types                           ----*/
proc sql;
  create
     table havMix(where=(not missing(num2chr))) as
  select
     memname
    ,name
    ,type
    ,case (type)
       when ('char') then catx(" ","input(",name,",best32.) as", name)
       else " "
     end as num2chr
  from
    sashelp.vcolumn
  where
    libname = "MIX"
  group
    by name
  having
    count(distinct type) = 2
;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* Manually fix the problematic mixed types.                                                                              */
/* Two tables need to be fixed, so we will create                                                                         */
/* corrected copies in the work directory.                                                                                */
/* I experimented with a programmatic solution but it was too complex and                                                 */
/* dangerous to modify the original data in place.                                                                        */
/*                                                                                                                        */
/* Up to 40 obs from last table WORK.HAVMIX total obs=2 22APR2023:10:22:04                                                */
/*                                                                                                                        */
/* Obs    MEMNAME    NAME    TYPE              NUM2CHR                                                                    */
/*                                                                                                                        */
/*  1     HAVTRE     AGE     char    input( AGE ,best32.) as AGE                                                          */
/*  2     HAVTWO     AGE     char    input( AGE ,best32.) as AGE                                                          */
/*                                                                                                                        */
/**************************************************************************************************************************/
/*__ _        _        _     _
 / _(_)_  __ | |_ __ _| |__ | | ___  ___
| |_| \ \/ / | __/ _` | `_ \| |/ _ \/ __|
|  _| |>  <  | || (_| | |_) | |  __/\__ \
|_| |_/_/\_\  \__\__,_|_.__/|_|\___||___/

*/
/*---- variables with mixed types                           ----*/

proc sql;
  create
      table havTwo  as
      select
          input( AGE ,best32.) as AGE
        , *
      from
          mix.havTwo
;quit;
/*---- ignore warning SAS uses 1st first Age                ----*/

/*----- copy on NumwChr statement                           ----*/
proc sql;
  create
      table havTre  as
      select
          input( AGE ,best32.) as AGE
        , *
      from
          mix.havTre
;quit;
/*---- ignore warning SAS uses 1st first Age                ----*/

/*   _             _      _        _     _
 ___| |_ __ _  ___| | __ | |_ __ _| |__ | | ___  ___
/ __| __/ _` |/ __| |/ / | __/ _` | `_ \| |/ _ \/ __|
\__ \ || (_| | (__|   <  | || (_| | |_) | |  __/\__ \
|___/\__\__,_|\___|_|\_\  \__\__,_|_.__/|_|\___||___/

*/

data want;
  retain fro;
  set
    mix.havOne  /*---- already numeric                      ----*/
   work.havTwo
   work.havTre  indsname=from
  ;
  fro = from;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* Up to 40 obs from last table WORK.WANT total obs=9 22APR2023:11:43:48                                                  */
/*                                                                                                                        */
/* Obs        FRO         NAME     SEX    AGE    WEIGHT                                                                   */
/*                                                                                                                        */
/*  1     MIX.HAVONE     Joyce      F      11       .                                                                     */
/*  2     MIX.HAVONE     Louise     F      12       .                                                                     */
/*  3     MIX.HAVONE     Alice      F      13       .                                                                     */
/*                                                                                                                        */
/*  4     WORK.HAVTWO    Joyce      F      44     50.5                                                                    */
/*  5     WORK.HAVTWO    Louise     F     150     77.0                                                                    */
/*  6     WORK.HAVTWO    Alice      F     128     84.0                                                                    */
/*                                                                                                                        */
/*  7     WORK.HAVTRE    Joyce      F      44       .                                                                     */
/*  8     WORK.HAVTRE    Louise     F     150       .                                                                     */
/*  9     WORK.HAVTRE    Alice      F     128       .                                                                     */
/*                                                                                                                        */
/*   Variable    Type    Len                                                                                              */
/*                                                                                                                        */
/*   FRO         Char     41                                                                                              */
/*   NAME        Char      8                                                                                              */
/*   SEX         Char      1                                                                                              */
/*   AGE         Num       8   All numeric                                                                                */
/*   WEIGHT      Num       8                                                                                              */
/*                                                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/
/*                              _       _   _
__      ___ __  ___   ___  ___ | |_   _| |_(_) ___  _ __
\ \ /\ / / `_ \/ __| / __|/ _ \| | | | | __| |/ _ \| `_ \
 \ V  V /| |_) \__ \ \__ \ (_) | | |_| | |_| | (_) | | | |
  \_/\_/ | .__/|___/ |___/\___/|_|\__,_|\__|_|\___/|_| |_|
         |_|
*/

%utl_submit_wps64('

libname mix "d:/mix";

proc sql;
  create
     table havMix(where=(not missing(num2chr))) as
  select
     memname
    ,name
    ,type
    ,case (type)
       when ("char") then catx(" ","input(",name,",best32.) as", name)
       else " "
     end as num2chr
  from
    dictionary.columns
  where
    libname = "MIX"
  group
    by name
  having
    count(distinct type) = 2
  ;
  create
      table havTwo  as
      select
          input( AGE ,best32.) as AGE
        , *
      from
          mix.havTwo
  ;
  create
      table havTre  as
      select
          input( AGE ,best32.) as AGE
        , *
      from
          mix.havTre
;quit;
data want;
  set
   mix.havOne
   havTwo
   havTre  /*---- NOT SUPPORTED indsname=from               ----*/
  ;
run;quit;

proc print ;
run;quit;
');


/**************************************************************************************************************************/
/*                                                                                                                        */
/*  The WPS System                                                                                                        */
/*                                                                                                                        */
/*  Obs     NAME     SEX    AGE    WEIGHT                                                                                 */
/*                                                                                                                        */
/*   1     Joyce      F      11       .                                                                                   */
/*   2     Louise     F      12       .                                                                                   */
/*   3     Alice      F      13       .                                                                                   */
/*   4     Joyce      F      44     50.5                                                                                  */
/*   5     Louise     F     150     77.0                                                                                  */
/*   6     Alice      F     128     84.0                                                                                  */
/*   7     Joyce      F      44       .                                                                                   */
/*   8     Louise     F     150       .                                                                                   */
/*   9     Alice      F     128       .                                                                                   */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
