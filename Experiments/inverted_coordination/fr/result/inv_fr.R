rm(list = ls())
library(tidyverse)
library(lme4)
library(lmerTest)
library(stringr)
library(readxl)
library(stringr)


###Number Vsg et Vsg  Ns/Np and/or
###read the input items
d_fr_item_num_inv = read.csv('~/rnn-coord/inverted-fr/items_num_inv.txt',sep="\t", header = TRUE) 
d_fr_item_num_inv$word=as.character(d_fr_item_num_inv$word)
d_fr_item_num_inv=subset(d_fr_item_num_inv, word!= "<eos>")

###read the results RNNG 
d_fr_res_num_inv_RNNG = read.csv('~/rnn-coord/inverted-fr/surprisals-inv_number_fr-rnng.txt',sep="\t", header = FALSE) 
names(d_fr_res_num_inv_RNNG)=c("word1","surprisal")
d_fr_res_num_inv_RNNG$model="RNNG"
d_fr_res_num_inv_RNNG$word1=as.character(d_fr_res_num_inv_RNNG$word1)
d_fr_res_num_inv_RNNG=subset(d_fr_res_num_inv_RNNG, word1!= "<eos>")


###read the results RNNG actiononly
d_fr_res_num_inv_RNNGaction = read.csv('~/rnn-coord/inverted-fr/surprisals-inv_number_fr-actiononly.txt',sep="\t", header = FALSE) 
names(d_fr_res_num_inv_RNNGaction)=c("word1","surprisal")
d_fr_res_num_inv_RNNGaction$model="ActionLSTM"
d_fr_res_num_inv_RNNGaction$word1=as.character(d_fr_res_num_inv_RNNGaction$word1)
d_fr_res_num_inv_RNNGaction=subset(d_fr_res_num_inv_RNNGaction, word1!= "<eos>")

###read tiny LSTM
d_fr_res_num_inv_RNNGtiny = read.csv('~/rnn-coord/inverted-fr/surprisals-inv_number_fr-tinylstm.txt',sep="\t", header = FALSE) 
names(d_fr_res_num_inv_RNNGtiny)=c("word1","surprisal")
d_fr_res_num_inv_RNNGtiny$model="LSTM (FTB)"
d_fr_res_num_inv_RNNGtiny$word1=as.character(d_fr_res_num_inv_RNNGtiny$word1)
d_fr_res_num_inv_RNNGtiny=subset(d_fr_res_num_inv_RNNGtiny, word1!= "<eos>")



###read data from large LSTM

d_fr_res_num_LSTM = read.csv('~/rnn-coord/inverted-fr/surprisals-inv_number_fr-biglstm.txt',sep="\t", header = FALSE) 
names(d_fr_res_num_LSTM)= c("word1","surprisal")
d_fr_res_num_LSTM$model="LSTM (frWaC)"

#combine items and results
d_fr_num_inv_RNNG=data.frame(d_fr_item_num_inv,d_fr_res_num_inv_RNNG)
d_fr_num_inv_RNNGaction=data.frame(d_fr_item_num_inv,d_fr_res_num_inv_RNNGaction)
d_fr_num_inv_tinyLSTM=data.frame(d_fr_item_num_inv,d_fr_res_num_inv_RNNGtiny)
d_fr_num_inv_LSTM=data.frame(d_fr_item_num_inv,d_fr_res_num_LSTM)

###combine models
d_fr_num_inv=rbind(d_fr_num_inv_RNNG,d_fr_num_inv_LSTM, d_fr_num_inv_RNNGaction, d_fr_num_inv_tinyLSTM)

###remove UNK
d_fr_num_inv=d_fr_num_inv%>%group_by(sent_index)%>%
  filter(all(!(str_detect(word1, "UNK"))))%>%
  ungroup()

###selct useful columnes and the conditions
d_fr_num_inv=d_fr_num_inv%>%select(region, condition,surprisal,sent_index,model) %>%
  subset(region =="and"|region =="or" ) %>%
  separate(condition, sep="-", into=c("Verb", "NP","Conj"))%>%
  unite("Condition", Verb, NP)

std <- function(x) sd(x)/sqrt(length(x))
d_fr_inv_res_agg = d_fr_num_inv%>%
  group_by(Condition, Conj,model) %>%
  summarise(m=mean(surprisal),
            s= std(surprisal),
            upper=m + 1.96*s,
            lower=m - 1.96*s) %>%
  ungroup()

d_fr_inv_res_agg= d_fr_inv_res_agg %>%
  filter(Conj=="and")%>%
  filter(Condition=="Vpl_Npl"|Condition=="Vpl_Nsg"|Condition=="Vsg_Nsg")

d_fr_inv_res_agg$Condition =factor(d_fr_inv_res_agg$Condition, c("Vpl_Npl", "Vpl_Nsg", "Vsg_Nsg"))



d_fr_inv_res_agg$model=factor(d_fr_inv_res_agg$model, c("LSTM (frWaC)","LSTM (FTB)","ActionLSTM", "RNNG"))


inv_fr3<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_fr_inv_res_agg) +
  geom_bar(stat="identity", position="dodge", linetype="dashed") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  theme(axis.text.x = element_text(angle = 60, hjust = 1, vjust =1 ))+
  facet_wrap(~model,ncol = 5)+ 
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933"))+
  labs(y = "Surprisal")+ 
  ylim(0,8)+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")

inv_fr3

ggsave("inv_fr_3.pdf",inv_fr3, width=5.04, height=1.88)
