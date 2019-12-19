library(glue)
library(readr)
library(magrittr)


rootDirectory <- getwd() # Set your root directory

niUniversities <- list(
  institution = c(
    "Queen's University Belfast", 
    "University of Ulster"),
  ukprn = c(
    10005343, 
    10007807))

employment.data <- read_csv(
  file = "{rootDirectory}EMPLOYMENT.csv" %>%
    glue())
subject.id.data <- read_csv(
  file = "{rootDirectory}KISCOURSE.csv" %>% 
    glue())

ni.employment.data <- employment.data %>% 
  subset(.$UKPRN %in% niUniversities$ukprn)

ni.employment.data$COURSETITLE <- subject.id.data$TITLE[
  match(ni.employment.data$KISCOURSEID, subject.id.data$KISCOURSEID)]
ni.employment.data$INSTITUTION <- ifelse(
  test = ni.employment.data$UKPRN == 10005343,
  yes = "Queen's University Belfast",
  no = "University of Ulster")

# Write NI CSV
ni.employment.data %>%
  write.csv2(
    file = "{rootDirectory}NI_EMPLOYMENT.csv" %>% 
      glue())

aggregated.employment <- list(
  courseId = c(),
  courseTitle = c(),
  unemploymentRate = c())

courseIds <- ni.employment.data$KISCOURSEID %>%
  unique()

for (id in courseIds) {
  subsetted.data <- ni.employment.data %>% 
    subset(.$KISCOURSEID == id)
  aggregated.employment$courseId %<>% 
    append(id)
  aggregated.employment$courseTitle %<>%
    append(subject.id.data$TITLE[
      match(id, subject.id.data$KISCOURSEID)])
  aggregated.employment$unemploymentRate %<>%
    append(
      subsetted.data$ASSUNEMP %>% 
        mean())
}

df <- aggregated.employment %>% 
  as.data.frame()
