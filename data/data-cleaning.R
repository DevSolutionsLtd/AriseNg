# data-cleaning.R

lapply(c('here',
         'readxl',
         'tidyverse',
         'NARCcontacts',
         'RSQLite',
         'magrittr'),
       library,
       character.only = TRUE)
source(file.path(here(), 'data', 'helpers.R'))

newColNames <- c(
  'registrant',
  'title',
  'gender',
  'surname',
  'other.names',
  'phone1',
  'phone2',
  'email',
  'occupation',
  'organisation',
  'location'
)

readData <- map_chr(c(
  'Arise-Nigeria-registered-participants.xlsx',
  'Arise_Nigeria_Conference_Reg_List_2nd batch.xlsx'
),
function(file)
  dataDirPath(file)) %>%
  map(function(x) {
    read_excel(x, sheet = spreadsheetName(x)) %>%
      select(Registrant:`City/Town`) %>% 
      setNames(newColNames) %>%
      mutate(phone1 = fix_phone_numbers(phone1)) %>%
      mutate(phone2 = fix_phone_numbers(phone2)) %>%
      add_remark_col()
  })

data1 <- readData[[1]] %>% 
  see()

data1 %<>%
  mutate(remark = ifelse(
    grepl('^female$|^male$', gender, ignore.case = TRUE),
    NA_character_,
    'Typo'
  ))

see(data1)
all(is.na(data1$remark))

female.abbr <- "F"
male.abbr <- "M"

data1$gender %<>%
  str_replace(regex('^f.?mal.+', ignore_case = TRUE), female.abbr) %>% 
  str_replace(regex('^mala?e$', ignore_case = TRUE), male.abbr)


if (interactive()) {
  data1 %>%
    use_series(gender) %>%
    unique() %>%
    str_replace('^F|M$', NA_character_) %>%
    map_df(function(x)
      bad_gender_entry(data1, x))
}

fix_gender <- function(df, old, new) {
  df$gender %<>%
    replace(which(. == old), new)
  df
}

data1 <- fix_gender(data1, 'PASTOR', male.abbr)
data1 %<>% fix_gender('AMOS', female.abbr)
data1 %<>% fix_gender('QUEEN', female.abbr)
data1 %<>% fix_gender('MRS', female.abbr)
data1 %<>% fix_gender('AKINBADE', male.abbr)

# ---

(data2 <- readData[[2]])

data2 %<>% 
  rename(tmp = other.names) %>% 
  rename(other.names = surname) %>% 
  rename(surname = gender) %>% 
  rename(gender = tmp) %>% 
  mutate(gender = str_to_title(gender)) %>% 
  mutate(gender = ifelse(gender == "Male", male.abbr, female.abbr))

# ---

preReg <-
  read_excel(dataDirPath('Arise-Nigeria_Pre-Registration.xlsx'), skip = 1) %>% 
  setNames(newColNames[c(1, 4, 3, 7, 5, 9) + 1]) %>% 
  mutate(registrant = 'Eventbrite') %>% 
  add_remark_col()

# ---

readData <- bind_rows(data1, data2, preReg)

readData %<>% mutate(title = str_to_title(title))

readData$occupation %<>%
  str_to_upper %>%
  str_replace('ACCOUNTING', 'ACCOUNTANT') %>% 
  str_replace("ASSITANT", "ASSISTANT") %>% 
  str_replace("ALL SAINTS KADO FISH MARKET", NA_character_) %>% 
  str_replace('^BUSINE.*|ENTREPRENEUR$', 'BUSINESS') %>% 
  str_replace('C\\.S|^CEV.+$', 'CIVIL SERVANT') %>% 
  str_replace('CHURCH', NA_character_) %>% 
  str_replace('COPER', 'NYSC MEMBER') %>% 
  str_replace('^DRIV.+$', 'DRIVER') %>% 
  str_replace('.*(ENTRE|ENTER)PR.+$', 'ENTREPRENEUR') %>% 
  str_replace('^EVANGIL', 'EVANGEL') %>% 
  str_replace('^FARM.+$', 'FARMER') %>% 
  str_replace('^FASHION$', 'FASHION DESIGNER') %>% 
  str_replace('^HAIR.+', 'HAIR DRESSER') %>% 
  str_replace('HANALIST', 'ANALYST') %>% 
  str_replace('HANDWORK\\/A\\.C', 'A/C TECHNICIAN') %>% 
  str_replace('^HOUSE.+', 'HOUSEWIFE') %>% 
  str_replace('LAGAL', 'LEGAL') %>% 
  str_replace("^MEDIA.+", "MEDIA") %>% 
  str_replace("(PARA).?MILITARY", "MILITARY") %>% 
  str_replace('^MINISTER.+$', 'MINISTER') %>% 
  str_replace('^(MUCIC|MUSIC|PIANIST).*', 'MUSICIAN') %>% 
  str_replace('NIL|NULL', NA_character_) %>% 
  str_replace('ASSISTANCE$', 'ASSITANT') %>% 
  str_replace('PASTORIAL', 'PASTOR') %>% 
  str_replace('^.*(RITIRE|RETIRE|RTD).*$', 'RETIRED') %>%
  str_replace('SURVEY$', 'SURVEYOR') %>% 
  str_replace('^SUDENT$|^STUDEN$', 'STUDENT') %>% 
  str_replace('^TAILOR.+', 'TAILOR') %>% 
  str_replace('^TEA.+', 'TEACHER') %>% 
  str_replace('^TRAD.+', 'TRADER') %>% 
  str_replace('WORKER', NA_character_) %>% 
  str_replace('MIINISTRY', 'MINISTRY') %>% 
  str_replace('PRACTIONER', 'PRACTITIONER') %>% 
  str_replace('PASTORING', 'PASTOR') %>% 
  str_replace('PROPHETE(S)', '\\1SS') %>% 
  str_replace('(SELF)(\\s)', '\\1-') %>% 
  str_replace(
    regex(
      paste0(
        "^A\\/C.+$|",
        ".+ELECTRICIAN$|",
        "BRICKLAYER|",
        "CLEANER|",
        "DRIVER|",
        "^FASHION.+|",
        "FURNITURE|",
        "HAIR DRESSER|",
        "LAUNDRY|",
        "MASON|",
        "^MECHANIC.+$|",
        "P\\.O\\.P.+$|",
        "PLUMBER|",
        "WELDER|",
        "STYLIST|",
        "TAILOR|",
        "TECHNICIAN"
      )
    ),
    "ARTISAN"
    ) %>% 
  str_replace("METRON", "NURSE") %>% 
  str_replace("ATTORNEY", "LEGAL PRACTITIONER") %>% 
  str_replace(".+BANKER|CASHIER", "BANKER") %>% 
  str_replace('^CLERGE$|PASTOR|EVANGELIST|^PREACHER.+|MINISTER|MISSIONARY|^SERVANT.+$', 'CLERGY') %>% 
  str_replace("PROGRAMMER|ANIMATOR|^GRAPHIC.+", "IT PROFESSIONAL") %>% 
  str_replace(
    regex("^ANALYST|AVIATOR|^BIKING.+|^BRAND.+|.*CONSULTANT.*|^DEVT.+$|^GDS.+$|^INDUSTRIAL.+$|.+MANAGER|MAID|^OFFICE.+|SOCIAL|^SSS$|TRAINER|^WRITER.+"),
    "MISCELLANEOUS"
    ) %>% 
  str_replace("^(CIVIL|PUBLIC)\\sSERVANT$", "CIVIL/PUBLIC SERVANT") %>% 
  str_replace("SELF-EMPLOYED|TRADER", "BUSINESS") %>% 
  str_replace("BUSINESS", "ENTREPRENEUR")

odd.occup.entries <- 
  c(
    "ALL SAINTS KADO FISH MARKET",
    "AMOUR OF GOD SULEJA",
    "ARMY OF GOD MINISTRY",
    "BELIEVERS GOSPEL MISSION GWA GWA",
    "CHRIST ASCENSION IDU KARMO",
    "DIVINE NATURE CHRISTIAN CENTRE",
    "DOMINION FIGHTERS DELIVERANCE MINISTRY",
    "DOMINION FIGHTERS DELIVERNACE MINISTRY",
    "ECWA",
    "F",
    "FIRM FOUNDATION ABA",
    "FOOD DOCTOR",
    "GREAT DYNAMITE FLAME FIRE ASSEMBLY KUJE",
    "GREAT JESUS CHAPEL KUJE",
    "HARVEST HOUSE INTERNATIONAL MISSIONS KURUDU ABUJA",
    "KARMO",
    "LIVING FAITH AKWANGA",
    "LIVING FAITH BAKASSI SULEJA",
    "MOUNTAIN OF FIRE KEFFI",
    "NATIONAL HOLY GHOST",
    "PENTEWCOSTAL FIRE PROPHETIC MINISTRY",
    "PFN/DU",
    "RCCG GWA GWA KARMO",
    "REDEEMED FRUITFUL RANCH MASAKA",
    "REDEEMED GWA GWA KARMO",
    "RHEMA CHAPEL INTERNATONAL KADO ABUJA",
    "THE WHOLE ARMY OF GOD",
    "THRONE",
    "TRINITARIAN",
    "UKOLA", 
    "UNGRAG",
    "VALE OF HEBRON"   
  )

readData$occupation %<>% 
{
  logi <- . %in% odd.occup.entries
  ifelse(logi, NA_character_, .)
}

readData$location %<>%
  str_replace(regex('.*(abuja|mpape|mpapa).*', ignore_case = TRUE), 'ABUJA') %>%
  str_replace(regex('.*lagos.*', ignore_case = TRUE), 'LAGOS') %>%
  str_replace('(MARA)(BA)', '\\1RA\\2') %>% 
  str_replace(regex('.*sula?eja.*|kadina.*', ignore_case = TRUE), 'SULEJA') %>%
  str_replace('AKWAN?GA.*', 'AKWANGA') %>%
  str_replace('ANAM?BRA.*$', 'ANAMBRA STATE') %>%
  str_replace('^(DIKO).*', '\\1') %>% 
  str_replace('^(JOS).*', '\\1') %>% 
  str_replace('^KAF.*$', 'KAFANCHAN') %>% 
  str_replace('^(KEFFI).*', '\\1') %>%
  str_replace('^(LAFIA).*', '\\1') %>% 
  str_replace('^(MADALA).*', '\\1') %>% 
  str_replace(
    regex(
      paste0(
        "ASOKORO",
        "|BWARI",
        "|BUARI",
        "|CARIMO",
        "|DIE DIE",
        "|DUTSE",
        "|FCT",
        "|^GWAGWA$",
        "|^GWARINPA$",
        "|IDU.*",
        "|JABI",
        "|JIK.+",
        "|^KAR.*",
        "|^KORUDO$",
        "|KUBWA",
        "|LIFE.+",
        "|LUGBE",
        "|^N?YANYAN?$",
        "|OROZO",
        "|USHAFA.*",
        "|WUSE.*"
      )
    ),
    'ABUJA'
  ) %>%
  str_to_upper('Nsukka') %>%
  str_replace(regex("OVERCOMER WORD ASSEMBLE|DIVINENATURECHRISTIANCENTER22|NCCHQ"),
              NA_character_) %>%
  str_replace('^PH.{5}|PORT.+', 'PORT HARCOURT') %>%
  str_replace('^(SABON-WUSE)(.*)', 'NEW WUSE') %>% 
  str_replace('^TAFA.*', 'TAFA') %>% 
  str_replace('ZARIA.*', 'ZARIA') %>% 
  str_replace("^(MINNA).*", "\\1") %>% 
  str_replace("^(MARARABA).+", "\\1") %>% 
  str_replace("^(BENIN).*", "\\1") %>% 
  str_replace("^(LAFIA).*", "\\1") %>% 
  str_replace('^DIKKIO.+', 'DIKO') %>% 
  str_replace('(.+)(UKE)$', '\\2') %>% 
  str_replace(fixed("GWAGWA"), "ABUJA")

## Export the data -----------------------------------------------------
write_excel_csv(
  readData, 
  path = dataDirPath('arisenigeria-registration-complete.csv'))

sum(!is.na(readData$phone1)) + sum(!is.na(readData$phone2))

# Get phone numbers
phoneNumbersOnly <- readData %>% 
  select(phone1:phone2)

write_excel_csv(phoneNumbersOnly,
                path = dataDirPath('arisenigeria-phonenumbers.csv'))

# Get phone numbers without NAs
write_excel_csv(
  phoneNumbersOnly,
  na = "",
  path = dataDirPath('arisenigeria-phoneNoNas.csv')
)

fileP <- dataDirPath('Arise-Nigeria-registered-participants.xlsx')
registrants <- read_excel(fileP, sheet = spreadsheetName(fileP))

if (!interactive())
  cat('Saving to database...')

dblink <- dbConnect(SQLite(), dataDirPath("arise_nigeria.db"))

try({
  dbWriteTable(
    dblink,
    'all_registrations',
    readData,
    overwrite = TRUE,
    field.types = c(phone1 = 'character', phone2 = 'character')
  )
   
  dbWriteTable(dblink, 'registrants', registrants, overwrite = TRUE)
})

dbDisconnect(dblink)

if (!interactive()) {
  if (!dbIsValid(dblink))
    cat('DB disconnected')
}
