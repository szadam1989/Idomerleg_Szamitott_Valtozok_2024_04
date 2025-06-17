library("openxlsx")
library("stringr")
library("lubridate")
library("roperators")
NEV_1 <- read.xlsx(paste("Excel", "1.NÉ_teszthez.xlsx", sep = "/"), sheet = "Munka1")
dim(NEV_1) # 2440 sor és 1677 oszlop

NEV_1$FIBD003 <- str_pad(NEV_1$FIBD003, width = 2, pad = "0")
NEV_1$FIBD004 <- str_pad(NEV_1$FIBD004, width = 2, pad = "0")
NEV_1$FIBD027 <- str_pad(NEV_1$FIBD027, width = 2, pad = "0")
NEV_1$FIBD028 <- str_pad(NEV_1$FIBD028, width = 2, pad = "0")

tevlista <- read.xlsx(paste("Excel", "tevlista.xlsx", sep = "/"), sheet = "Munka1")
dim(tevlista) # 366 sor és 2 oszlop

tartamok <- as.data.frame(matrix(NA, nrow = nrow(NEV_1), ncol = 62))
colnames(tartamok) <- c(paste0("TARTAM_", 1:62))

tartam <- NEV_1[, c("TEV", "ISZAK", "OSAP_REG",	"LAKAZON", "FIBD002", "FIBD003", "FIBD004", "FIBD026", "FIBD027", "FIBD028")]

for(i in 1:62){
  
  tartam <- cbind(tartam, NEV_1[, c(paste0("FOTEV_KOD_", i), paste0("FIBC126_", i), paste0("FIBC111_", i))], tartamok[, c(paste0("TARTAM_", i))])
  colnames(tartam)[ncol(tartam)] <- paste0("TARTAM_", i)
  
}


for(i in 1:nrow(NEV_1)){
  
  if(is.na(tartam[i, "FIBD002"]) == FALSE)
    date_submit <- ymd(paste0(tartam[i, "FIBD002"], "-", tartam[i, "FIBD003"], "-", tartam[i, "FIBD004"]))
  else
    date_submit <- ymd(paste0(tartam[i, "FIBD026"], "-", tartam[i, "FIBD027"], "-", tartam[i, "FIBD028"]))
  
  for(j in 1:62){
    
    if (is.na(str_sub(NEV_1[i, paste0("FIBC111_", j)])) == TRUE)
        break
    
    if ((str_sub(NEV_1[i, paste0("FIBC111_", j)], start = 1, end = 2) == "00" | str_sub(NEV_1[i, paste0("FIBC111_", j)], start = 1, end = 2) == "01" | str_sub(NEV_1[i, paste0("FIBC111_", j)], start = 1, end = 2) == "02" | str_sub(NEV_1[i, paste0("FIBC111_", j)], start = 1, end = 2) == "03") & ((str_sub(NEV_1[i, paste0("FIBC126_", j)], start = 1, end = 2) != "00" & str_sub(NEV_1[i, paste0("FIBC126_", j)], start = 1, end = 2) != "01" & str_sub(NEV_1[i, paste0("FIBC126_", j)], start = 1, end = 2) != "02" & str_sub(NEV_1[i, paste0("FIBC126_", j)], start = 1, end = 2) != "03")))
      tartam[i, paste0("TARTAM_", j)] <- as.numeric(difftime(ymd_hms(paste0(date_submit + days(1), " ", NEV_1[i, paste0("FIBC111_", j)], ":00")), ymd_hms(paste0(date_submit, " ", NEV_1[i, paste0("FIBC126_", j)], ":00")), units = "mins"))
    else if ((str_sub(NEV_1[i, paste0("FIBC111_", j)], start = 1, end = 2) == "00" | str_sub(NEV_1[i, paste0("FIBC111_", j)], start = 1, end = 2) == "01" | str_sub(NEV_1[i, paste0("FIBC111_", j)], start = 1, end = 2) == "02" | str_sub(NEV_1[i, paste0("FIBC111_", j)], start = 1, end = 2) == "03") & (str_sub(NEV_1[i, paste0("FIBC126_", j)], start = 1, end = 2) == "00" | str_sub(NEV_1[i, paste0("FIBC126_", j)], start = 1, end = 2) == "01" | str_sub(NEV_1[i, paste0("FIBC126_", j)], start = 1, end = 2) == "02" | str_sub(NEV_1[i, paste0("FIBC126_", j)], start = 1, end = 2) == "03"))
      tartam[i, paste0("TARTAM_", j)] <- as.numeric(difftime(ymd_hms(paste0(date_submit + days(1), " ", NEV_1[i, paste0("FIBC111_", j)], ":00")), ymd_hms(paste0(date_submit + days(1), " ", NEV_1[i, paste0("FIBC126_", j)], ":00")), units = "mins"))
    else
      tartam[i, paste0("TARTAM_", j)] <- as.numeric(difftime(ymd_hms(paste0(date_submit, " ", NEV_1[i, paste0("FIBC111_", j)], ":00")), ymd_hms(paste0(date_submit, " ", NEV_1[i, paste0("FIBC126_", j)], ":00")), units = "mins"))
    
  }
  
}

gc()

dim(tartam) # 2440 sor és 258 oszlop

tevlista <- tevlista[nchar(tevlista$Kód) > 2, ]
dim(tevlista)

tevlista_kodok_A <- as.data.frame(matrix(0, nrow = nrow(tartam), ncol = nrow(tevlista)))
colnames(tevlista_kodok_A) <- c(paste0("Mut_A_", c(tevlista$Kód)))

tevlista_kodok_B <- as.data.frame(matrix(0, nrow = nrow(tartam), ncol = nrow(tevlista)))
colnames(tevlista_kodok_B) <- c(paste0("Mut_B_", c(tevlista$Kód)))

tevlista_kodok_C <- as.data.frame(matrix(0, nrow = nrow(tartam), ncol = nrow(tevlista)))
colnames(tevlista_kodok_C) <- c(paste0("Mut_C_", c(tevlista$Kód)))

tevlista_kodok <- cbind(tevlista_kodok_A, tevlista_kodok_B, tevlista_kodok_C)

x <- c()
for (i in 1:335) 
  x <- c(x, seq(from = i, to = 1005, by = 335))

tevlista_kodok <- tevlista_kodok[, x]

# tartam <- tartam[, c(1:258)]
tartam <- cbind(tartam, tevlista_kodok)
dim(tartam) # 2440 sor és 1263 oszlop

for(i in 1:nrow(tartam)){
  
  for(j in 1:nrow(tevlista)){
    
    contains <- tartam[i, paste0("FOTEV_KOD_", 1:62)] == tevlista[j, "Kód"]
    if (nrow(contains) == 0)
      next
    
    oszto <- sum(contains, na.rm = TRUE)
    
    for(k in 1:ncol(contains)){
      
      if (is.na(contains[1, k]) == TRUE)
        next
      
      if(contains[1, k] != TRUE)
        next
      
      tartam[i, paste0("Mut_A_", tevlista[j, "Kód"])] %+=% tartam[i, c(paste0("TARTAM_", k))]
      tartam[i, paste0("Mut_B_", tevlista[j, "Kód"])] <- 100
      tartam[i, paste0("Mut_C_", tevlista[j, "Kód"])] %+=% tartam[i, c(paste0("TARTAM_", k))]
      
    }
    
    if (oszto != 0)
      tartam[i, paste0("Mut_A_", tevlista[j, "Kód"])] <- tartam[i, paste0("Mut_A_", tevlista[j, "Kód"])] / oszto

  }
  
}

write.xlsx(tartam, "Számított_változók_képzése_20250616.xlsx", overwrite = TRUE)


