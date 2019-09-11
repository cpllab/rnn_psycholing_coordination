rm(list = ls())
library(tidyverse)
library(lme4)
library(lmerTest)
library(stringr)
library(readxl)

###Number I went to the park and the garden
###read the input items

d_fr_item_gender = read.csv('~/rnn-coord/complex_gender/items_complex_gender.txt',sep="\t", header = TRUE) 
d_fr_item_gender$word=as.character(d_fr_item_gender$word)
d_fr_item_gender_noend=subset(d_fr_item_gender, word!= "<eos>")



d_fr_gender_action = read.csv('~/rnn-coord/complex_gender/surprisals-complex_gender_fr-actiononly.txt',sep="\t", header = FALSE) 
colnames(d_fr_gender_action)=c("word1","surprisal")
d_fr_gender_action$model= "ActionLSTM"

d_fr_gender_rnng = read.csv('~/rnn-coord/complex_gender/surprisals-complex_gender_fr-rnng.txt',sep="\t",header = FALSE) 
colnames(d_fr_gender_rnng)=c("word1","surprisal")
d_fr_gender_rnng$model="RNNG"

d_fr_gender_tinylstm = read.csv('~/rnn-coord/complex_gender/surprisals-complex_gender_fr-tinylstm.txt',sep="\t", header = FALSE) 
colnames(d_fr_gender_tinylstm)=c("word1","surprisal")
d_fr_gender_tinylstm$model="LSTM (FTB)"

d_gender_action=data.frame(d_fr_item_gender,d_fr_gender_action)
d_gender_tinylstm=data.frame(d_fr_item_gender,d_fr_gender_tinylstm)
d_gender_RNNG=data.frame(d_fr_item_gender,d_fr_gender_rnng)


####read LSTM
d_fr_gender_LSTM = read.csv('~/rnn-coord/complex_gender/surprisals-complex_gender_fr-biglstm.txt',sep="\t", header = FALSE) 
colnames(d_fr_gender_LSTM)=c("word1","surprisal")
d_fr_gender_LSTM$model="LSTM (frWaC)"
d_fr_gender_LSTM=data.frame(d_fr_item_gender_noend,d_fr_gender_LSTM)

d_gender=rbind(d_gender_action, d_gender_tinylstm,d_gender_RNNG, d_fr_gender_LSTM)


d_gender=d_gender%>%group_by(sent_index)%>%
  filter(all(!(str_detect(word1, "UNK"))))%>%
  ungroup()

d_gender_verb=d_gender%>%select(region, condition,surprisal,model,sent_index) %>%
  subset(region =="Masc"|region =="Fem" ) %>%
  separate(condition, sep="_", into=c("prefix", "and","N1","N2","Verb" )) %>%
  filter(prefix=="verb" )%>%
  unite("Condition",  N1,and,N2)

d_gender_verb_2= d_gender_verb%>%
  select(-region)%>%
  spread (Verb, surprisal )%>%
  mutate(diff=Vf-Vm)

length(d_gender_verb_2$diff)/16

std <- function(x) sd(x)/sqrt(length(x))
d_gender_verb_2_agg = d_gender_verb_2 %>%
  group_by(Condition, model) %>%
  summarise(m=mean(diff),
            s= std(diff),
            upper=m + 1.96*s,
            lower=m - 1.96*s) %>%
  ungroup()
View(d_gender_verb_2_agg)



d_gender_verb_2_agg$Condition=factor(d_gender_verb_2_agg$Condition, c("and_Nm_Nm","and_Nf_Nm","and_Nm_Nf","and_Nf_Nf"))
levels(d_gender_verb_2_agg$Condition)= c("m_and_m","f_and_m","m_and_f","f_and_f")



d_gender_verb_2_agg$model=factor(d_gender_verb_2_agg$model, c("LSTM (frWaC)","LSTM (FTB)","ActionLSTM", "RNNG"))

d_gender_verb_complex<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_gender_verb_2_agg) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,ncol = 4)+
  labs(y = "S(f)-S(m)")+
  ylim(-3,4)+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

d_gender_verb_complex
ggsave("gender_verb_comlex.pdf",width=5.06, height=1.8)

#####verb

d_gender=rbind(d_gender_action, d_gender_tinylstm,d_gender_RNNG, d_fr_gender_LSTM)


d_gender=d_gender%>%group_by(sent_index)%>%
  filter(all(!(str_detect(word1, "UNK"))))%>%
  ungroup()

d_gender_that=d_gender%>%select(region, condition,surprisal,model,sent_index) %>%
  subset(region =="Masc"|region =="Fem" ) %>%
  separate(condition, sep="_", into=c("prefix", "and","N1","N2","Verb" )) %>%
  filter(prefix=="that" )%>%
  unite("Condition",  N1,and,N2)

d_gender_that_2= d_gender_that%>%
  select(-region)%>%
  spread (Verb, surprisal )%>%
  mutate(diff=Vf-Vm)

length(d_gender_that_2$diff)/16

std <- function(x) sd(x)/sqrt(length(x))
d_gender_that_2_agg = d_gender_that_2 %>%
  group_by(Condition, model) %>%
  summarise(m=mean(diff),
            s= std(diff),
            upper=m + 1.96*s,
            lower=m - 1.96*s) %>%
  ungroup()
View(d_gender_that_2_agg)



d_gender_that_2_agg$Condition=factor(d_gender_that_2_agg$Condition, c("and_Nm_Nm","and_Nf_Nm","and_Nm_Nf","and_Nf_Nf"))
levels(d_gender_that_2_agg$Condition)= c("m_and_m","f_and_m","m_and_f","f_and_f")



d_gender_that_2_agg$model=factor(d_gender_that_2_agg$model, c("LSTM (frWaC)","LSTM (FTB)","ActionLSTM", "RNNG"))

d_gender_that_complex<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_gender_that_2_agg) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,ncol = 4)+
  labs(y = "S(f)-S(m)")+
  ylim(-3.2,4)+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

d_gender_that_complex
ggsave("gender_that_complex.pdf",width=5.06, height=1.8)
