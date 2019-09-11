rm(list = ls())
library(tidyverse)
library(lme4)
library(lmerTest)
library(plotrix)
library(stringr)
library(readxl)

#####read results from Ethan
d_en_chunk_item= read.csv('~/rnn-coord/complex_en/items.txt',sep="\t") 
###remove . from the results


####read results of RNNG actiononly

d_en_chunk_RNNG_actiononly = read.csv('~/rnn-coord/complex_en/surprisals-complex_number_en-actiononly.txt',sep="\t",header = FALSE) 
colnames(d_en_chunk_RNNG_actiononly)=c("model_word","surprisal")
d_en_chunk_RNNG_actiononly$model= "ActionLSTM"
d_en_chunk_res_RNNG_actiononly=data.frame(d_en_chunk_item,d_en_chunk_RNNG_actiononly)

####read results of RNNG 

d_en_chunk_RNNG = read.csv('~/rnn-coord/complex_en/surprisals-complex_number_en-rnng.txt',sep="\t",header = FALSE) 

colnames(d_en_chunk_RNNG)=c("model_word","surprisal")
d_en_chunk_RNNG$model= "RNNG"
d_en_chunk_res_RNNG=data.frame(d_en_chunk_item,d_en_chunk_RNNG)

####read results of RNNG 

d_en_chunk_tinyLSTM = read.csv('~/rnn-coord/complex_en/surprisals-complex_number_en-tinylstm.txt',sep="\t",header = FALSE) 

colnames(d_en_chunk_tinyLSTM)=c("model_word","surprisal")
d_en_chunk_tinyLSTM$model= "LSTM (PTB)"
d_en_chunk_tinyLSTM=data.frame(d_en_chunk_item,d_en_chunk_tinyLSTM)


d_en_chunk_google = read.csv('~/rnn-coord/complex_en/surprisals-complex_number_en-google.txt',sep="\t",header = FALSE) 

colnames(d_en_chunk_google)=c("model_word","surprisal")
d_en_chunk_google$model= "Jozefowicz"
d_en_chunk_google=data.frame(d_en_chunk_item,d_en_chunk_google)


d_en_chunk_gulordava = read.csv('~/rnn-coord/complex_en/surprisals-complex_number_en-gulordava.txt',sep="\t",header = FALSE) 

colnames(d_en_chunk_gulordava)=c("model_word","surprisal")
d_en_chunk_gulordava$model= "Gulordava"
d_en_chunk_gulordava=data.frame(d_en_chunk_item,d_en_chunk_gulordava)
####combine all the data together
d_en_chunk_res=rbind(d_en_chunk_tinyLSTM, d_en_chunk_res_RNNG, d_en_chunk_res_RNNG_actiononly,d_en_chunk_google,d_en_chunk_gulordava)


####remove UNK,
d_en_chunk_res=d_en_chunk_res%>%group_by(sent_index)%>%
  filter(all(!(str_detect(model_word, "UNK"))))%>%
  ungroup()
###sent_index 7,27 removes, 35 sentences left

#####select the data and rename the conditions
d_en_chunk_res=d_en_chunk_res%>%select(region, condition,surprisal,model,sent_index) %>%
  subset(region =="is"|region =="are" ) %>%
  separate(condition, sep="-", into=c("Condition", "Verb"))

d_en_chunk_res= d_en_chunk_res%>%
  select(-region)%>%
  spread (Verb, surprisal )%>%
  mutate(diff=Vsg-Vpl)



std <- function(x) sd(x)/sqrt(length(x))


####aggregate the data
d_en_chunk_res_agg = d_en_chunk_res%>%
  group_by(Condition, model) %>%
  summarise(m=mean(diff),
          s= std(diff),
          upper=m + 1.96*s,
          lower=m - 1.96*s) %>%
  ungroup()


###odering factors

d_en_chunk_res_that_agg=subset(d_en_chunk_res_agg, Condition=="that_pl_pl"| Condition=="that_sg_pl"| Condition=="that_pl_sg"| Condition=="that_sg_sg")
d_en_chunk_res_that_agg$Condition=factor(d_en_chunk_res_that_agg$Condition,c("that_pl_pl","that_sg_pl","that_pl_sg","that_sg_sg"))
levels(d_en_chunk_res_that_agg$Condition)=c("pl_and_pl","sg_and_pl", "pl_and_sg", "sg_and_sg")

d_en_chunk_res_that_agg$model =factor(d_en_chunk_res_that_agg$model,c("Jozefowicz","Gulordava", "LSTM (PTB)","ActionLSTM", "RNNG" ))
levels(d_en_chunk_res_that_agg$model)=c("LSTM (1B)","LSTM (enWiki)", "LSTM (PTB)","ActionLSTM", "RNNG")

###plot
that_en2<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_en_chunk_res_that_agg) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,nrow = 1, ncol = 5)+
  ylim(-2, 15)+
  labs(y = "S(sg)-S(pl)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

that_en2
ggsave("that_en.pdf",width=5.06, height=1.8)




####For subset I went to the park and the garden is
d_en_chunk_res_verb_agg=subset(d_en_chunk_res_agg, Condition=="verb_pl_pl"| Condition=="verb_sg_pl"| Condition=="verb_pl_sg"| Condition=="verb_sg_sg")
d_en_chunk_res_verb_agg$Condition=factor(d_en_chunk_res_verb_agg$Condition,c("verb_pl_pl","verb_sg_pl","verb_pl_sg","verb_sg_sg"))
levels(d_en_chunk_res_verb_agg$Condition)=c("pl_and_pl","sg_and_pl", "pl_and_sg", "sg_and_sg")

d_en_chunk_res_verb_agg$model =factor(d_en_chunk_res_verb_agg$model,c("Jozefowicz","Gulordava", "LSTM (PTB)","ActionLSTM", "RNNG" ))

levels(d_en_chunk_res_verb_agg$model)=c("LSTM (1B)","LSTM (enWiki)", "LSTM (PTB)","ActionLSTM", "RNNG")

###plot

verb_en2<-ggplot( aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_en_chunk_res_verb_agg) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,nrow = 1, ncol = 5)+
  ylim(-10,10)+
  labs(y = "S(sg)-S(pl)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

verb_en2
ggsave("verb_en.pdf",width=5.06, height=1.8)
