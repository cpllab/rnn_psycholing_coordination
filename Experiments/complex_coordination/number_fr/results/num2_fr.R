rm(list = ls())
library(tidyverse)
library(lme4)
library(lmerTest)
library(stringr)
library(readxl)

###Number I went to the park and the garden
###read the input items

d_fr_item_num2 = read.csv('~/rnn-coord/complex_fr_num/items_num2.tsv',sep="\t", header = TRUE) 
d_fr_item_num2$word=as.character(d_fr_item_num2$word)
d_fr_item_num2_noend=subset(d_fr_item_num2, word!= "<eos>")
View(d_fr_item_num2_noend)


d_fr_res_num2_action = read.csv('~/rnn-coord/complex_fr_num/surprisals-complex_number_fr-actiononly.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_num2_action)=c("word1","surprisal")
d_fr_res_num2_action$model= "ActionLSTM"

d_fr_res_num2 = read.csv('~/rnn-coord/complex_fr_num/surprisals-complex_number_fr-rnng.txt',sep="\t",header = FALSE) 
colnames(d_fr_res_num2)=c("word1","surprisal")
d_fr_res_num2$model="RNNG"

d_fr_res_num2_tinylstm = read.csv('~/rnn-coord/complex_fr_num/surprisals-complex_number_fr-tinylstm.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_num2_tinylstm)=c("word1","surprisal")
d_fr_res_num2_tinylstm$model="LSTM (FTB)"

d_num2_action=data.frame(d_fr_item_num2,d_fr_res_num2_action)
d_num2_tinylstm=data.frame(d_fr_item_num2,d_fr_res_num2_tinylstm)
d_num2_RNNG=data.frame(d_fr_item_num2,d_fr_res_num2)


####read LSTM
d_fr_res_num2_LSTM = read.csv('~/rnn-coord/complex_fr_num/surprisals-complex_number_fr-biglstm.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_num2_LSTM)=c("word1","surprisal")
d_fr_res_num2_LSTM$model="LSTM (frWaC)"
d_fr_num2_LSTM=data.frame(d_fr_item_num2_noend,d_fr_res_num2_LSTM)

d_num2=rbind(d_num2_action, d_num2_tinylstm,d_num2_RNNG, d_fr_num2_LSTM)


d_num2=d_num2%>%group_by(sent_index)%>%
  filter(all(!(str_detect(word1, "UNK"))))%>%
  ungroup()

d_num2=d_num2%>%select(region, condition,surprisal,model,sent_index) %>%
  subset(region =="Vsg"|region =="Vpl" ) %>%
  separate(condition, sep="-", into=c("Condition", "Verb"))

d_num22= d_num2%>%
  select(-region)%>%
  spread (Verb, surprisal )%>%
  mutate(diff=Vsg-Vpl)

length(d_num2$surprisal)/64

std <- function(x) sd(x)/sqrt(length(x))
d_fr_num2_agg = d_num22 %>%
  group_by(Condition, model) %>%
  summarise(m=mean(diff),
            s= std(diff),
            upper=m + 1.96*s,
            lower=m - 1.96*s) %>%
  ungroup()
View(d_fr_num2_agg)

d_fr_num2_agg_that=d_fr_num2_agg%>%
  separate(Condition, sep="_", into=c("prefix","N1","N2" )) %>%
  subset(prefix=="que")%>%
  unite("Condition",N1,N2)



d_fr_num2_agg_that$Condition=factor(d_fr_num2_agg_that$Condition, c("pl_pl","sg_pl", "pl_sg", "sg_sg"))
levels(d_fr_num2_agg_that$Condition)=c("pl_and_pl","sg_and_pl", "pl_and_sg", "sg_and_sg")

d_fr_num2_agg_that$model=factor(d_fr_num2_agg_that$model, c("LSTM (frWaC)","LSTM (FTB)","ActionLSTM", "RNNG"))
  
num_that_fr3<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_fr_num2_agg_that) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,ncol = 4)+
  labs(y = "S(sg)-S(pl)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

num_that_fr3
ggsave("num_that_fr.pdf",width=5.06, height=1.8)

#####verb

d_fr_num2_agg_verb=d_fr_num2_agg%>%
  separate(Condition, sep="_", into=c("prefix","N1","N2" )) %>%
  subset(prefix=="verb")%>%
  unite("Condition",N1,N2)



d_fr_num2_agg_verb$Condition=factor(d_fr_num2_agg_verb$Condition, c("pl_pl","sg_pl", "pl_sg", "sg_sg"))
levels(d_fr_num2_agg_verb$Condition)=c("pl_and_pl","sg_and_pl", "pl_and_sg", "sg_and_sg")
d_fr_num2_agg_verb$model=factor(d_fr_num2_agg_verb$model, c("LSTM (frWaC)","LSTM (FTB)","ActionLSTM", "RNNG"))

num_verb_fr3<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper,fill=Condition), data=d_fr_num2_agg_verb) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,ncol = 4)+
  labs(y = "S(sg)-S(pl)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

num_verb_fr3
ggsave("num_verb_fr.pdf",width=5.06, height=1.8)

