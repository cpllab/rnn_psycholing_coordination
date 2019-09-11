rm(list = ls())
library(tidyverse)
library(lme4)
library(lmerTest)
library(stringr)
library(readxl)

###gender agreement
###read the input items


d_fr_item_gender = read.csv('~/rnn-coord/simple_gender/items_simple_gender.txt',sep="\t", header = TRUE) 
d_fr_item_gender$word=as.character(d_fr_item_gender$word)
d_fr_item_gender_noend=subset(d_fr_item_gender, word!= "<eos>")

### read results RNNG action only
d_fr_res_gender_action = read.csv('~/rnn-coord/simple_gender/surprisals-simple_gender_fr-actiononly.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_gender_action)=c("word1","surprisal")

d_fr_res_gender_action$model= "ActionLSTM"

### read results RNNG only
d_fr_res_gender = read.csv('~/rnn-coord/simple_gender/surprisals-simple_gender_fr-rnng.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_gender)=c("word1","surprisal")
d_fr_res_gender$model= "RNNG"

### read results tiny LSTM
d_fr_res_gender_tinylstm = read.csv('~/rnn-coord/simple_gender/surprisals-simple_gender_fr-tinylstm.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_gender_tinylstm)=c("word1","surprisal")
d_fr_res_gender_tinylstm$model="LSTM (FTB)"



####read LSTM
d_fr_res_gender_LSTM = read.csv('~/rnn-coord/simple_gender/surprisals-simple_gender_fr-biglstm.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_gender_LSTM)=c("word1","surprisal")
d_fr_res_gender_LSTM$model="LSTM (frWaC)"


###combine results and items
d_gender_action=data.frame(d_fr_item_gender,d_fr_res_gender_action)
d_gender_RNN=data.frame(d_fr_item_gender,d_fr_res_gender)
d_gender_tinyLSTM=data.frame(d_fr_item_gender,d_fr_res_gender_tinylstm)

d_fr_gender_LSTM=data.frame(d_fr_item_gender_noend,d_fr_res_gender_LSTM)

### combine four models
d_gender=rbind(d_gender_action,d_gender_RNN, d_gender_tinyLSTM, d_fr_gender_LSTM)


### remove unK
d_gender=d_gender%>%group_by(sent_index)%>%
  filter(all(!(str_detect(word1, "UNK-LC-ons"))))%>%
  ungroup()



####select data
d_gender=d_gender%>%select(region, condition,surprisal,model,sent_index) %>%
  filter(region =="Masc"|region =="Fem" ) %>%
  separate(condition, sep="_", into=c( "N1","and", "N2", "Verb"))%>%
  unite("Condition",  and, N1,N2)

d_gender2= d_gender%>%
  select(-region)%>%
  spread (Verb, surprisal )%>%
  mutate(diff=Vf-Vm)

d_gender2$sent_index
###aggregate


std <- function(x) sd(x)/sqrt(length(x))
d_gender_agg = d_gender2 %>%
  group_by(Condition,model ) %>%
  summarise(m=mean(diff),
            s= std(diff),
            upper=m + 1.96*s,
            lower=m - 1.96*s) %>%
  ungroup()





####plot

d_gender_agg$model=factor(d_gender_agg$model, c("LSTM (frWaC)","LSTM (FTB)","ActionLSTM", "RNNG"))

d_gender_agg$Condition
d_gender_agg_and=subset(d_gender_agg, Condition=="and_Nf_Nf"| Condition=="and_Nf_Nm"| Condition=="and_Nm_Nf"| Condition=="and_Nm_Nm")
d_gender_agg_or=subset(d_gender_agg, Condition=="or_Nf_Nf"| Condition=="or_Nf_Nm"| Condition=="or_Nm_Nf"| Condition=="or_Nm_Nm")

d_gender_agg_and$Condition=factor(d_gender_agg_and$Condition, c("and_Nm_Nm","and_Nf_Nm","and_Nm_Nf","and_Nf_Nf"))
levels(d_gender_agg_and$Condition)= c("m_and_m","f_and_m","m_and_f","f_and_f")
d_gender_agg_or$Condition=factor(d_gender_agg_or$Condition, c("or_Nm_Nm","or_Nf_Nm","or_Nm_Nf","or_Nf_Nf"))
levels(d_gender_agg_or$Condition)= c("m_or_m","f_or_m","m_or_f","f_or_f")

gender_fr_simple_and<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_gender_agg_and) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,ncol = 4)+
  labs(y = "S(f)-S(m)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

gender_fr_simple_and

ggsave("gender_fr_simple_and.pdf",width=5.04, height=1.88)

gender_fr_simple_or<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_gender_agg_or) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,ncol = 4)+
  labs(y = "S(f)-S(m)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

gender_fr_simple_or

ggsave("gender_fr_simple_or.pdf",width=5.04, height=1.88)


