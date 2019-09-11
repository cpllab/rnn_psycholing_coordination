rm(list = ls())
library(tidyverse)
library(lme4)
library(lmerTest)
library(plotrix)
library(stringr)
library(readxl)


###Number Vsg et Vsg is/are
###read the input items
d_fr_item_num = read.csv('~/rnn-coord/simple_number_fr/items.tsv',sep="\t", header = TRUE) 

###remove <eos>
d_fr_item_num$word=as.character(d_fr_item_num$word)
d_fr_item_num_noend=subset(d_fr_item_num, word!= "<eos>")

###read the results RNNG action only
d_fr_res_num_action = read.csv('~/rnn-coord/simple_number_fr/surprisals-simple_number_fr-actiononly.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_num_action)=c("word1","surprisal")
d_fr_res_num_action$model= "ActionLSTM"

###read the results RNNG
d_fr_res_num = read.csv('~/rnn-coord/simple_number_fr/surprisals-simple_number_fr-rnng.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_num)=c("word1","surprisal")
d_fr_res_num$model="RNNG"


###read the results tinyLSTM
d_fr_res_num_tinylstm = read.csv('~/rnn-coord/simple_number_fr/surprisals-simple_number_fr-tinylstm.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_num_tinylstm)=c("word1","surprisal")
d_fr_res_num_tinylstm$model="LSTM (FTB)"

###combine items and results
d_fr_num_action=data.frame(d_fr_item_num,d_fr_res_num_action)
d_fr_num_RNN=data.frame(d_fr_item_num,d_fr_res_num)
d_fr_num_tinyLSTM=data.frame(d_fr_item_num,d_fr_res_num_tinylstm)

####read LSTM
d_fr_res_num_LSTM = read.csv('~/rnn-coord/simple_number_fr/surprisals-simple_number_fr-biglstm.txt',sep="\t", header = FALSE) 
colnames(d_fr_res_num_LSTM)=c("word1","surprisal")
d_fr_res_num_LSTM$model="LSTM (frWaC)"
d_fr_num_LSTM=data.frame(d_fr_item_num_noend,d_fr_res_num_LSTM)

###combine three models
d_fr_num=rbind(d_fr_num_RNN,d_fr_num_action,d_fr_num_tinyLSTM, d_fr_num_LSTM)





###remove UNK
d_fr_num=d_fr_num%>%group_by(sent_index)%>%
  filter(all(!(str_detect(word1, "UNK"))))%>%
  ungroup()

###selct useful columnes and the conditions
d_fr_num=d_fr_num%>%select(region, condition,surprisal,model,sent_index) %>%
  subset(region =="Vsg"|region =="Vpl" ) %>%
  separate(condition, sep="-", into=c("Condition", "Verb"))  %>%
  separate(Condition, sep="_", into=c("Conj", "N1","N2"))%>%
  unite("Condition", N1,Conj, N2)


d_fr_num2= d_fr_num%>%
  select(-region)%>%
  spread (Verb, surprisal )%>%
  mutate(diff=Vsg-Vpl)



###24 items
length(d_fr_num$surprisal)/32

###aggregate
std <- function(x) sd(x)/sqrt(length(x))
d_fr_num_agg = d_fr_num2 %>%
  group_by(Condition, model) %>%
  summarise(m=mean(diff),
            s= std(diff),
            upper=m + 1.96*s,
            lower=m - 1.96*s) %>%
  ungroup()
d_fr_num_agg_and=subset(d_fr_num_agg, Condition== "pl_and_pl" |Condition=="sg_and_pl"|Condition== "pl_and_sg"|Condition== "sg_and_sg")
d_fr_num_agg_or=subset(d_fr_num_agg, Condition== "pl_or_pl" |Condition=="sg_or_pl"|Condition== "pl_or_sg"|Condition== "sg_or_sg")

###plotting

##d_fr_num_agg$Verb=factor(d_fr_num_agg$Verb, c("Vsg","Vpl"))
###levels(d_fr_num_agg$Verb)=c("singular", "plural")
d_fr_num_agg_and$Condition=factor(d_fr_num_agg_and$Condition, c("pl_and_pl",  "sg_and_pl", "pl_and_sg","sg_and_sg"))
d_fr_num_agg_and$model=factor(d_fr_num_agg_and$model, c("LSTM (frWaC)","LSTM (FTB)","ActionLSTM", "RNNG"))


num_fr_and5<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper,fill=Condition), data=d_fr_num_agg_and) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,ncol =4)+
  labs(y = "S(sg)-S(pl)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

num_fr_and5
ggsave("num_fr_and.pdf",width=5.06, height=1.8)

d_fr_num_agg_or$Condition=factor(d_fr_num_agg_or$Condition, c("pl_or_pl",  "sg_or_pl", "pl_or_sg","sg_or_sg"))

d_fr_num_agg_or$model=factor(d_fr_num_agg_or$model, c("LSTM (frWaC)","LSTM (FTB)","ActionLSTM", "RNNG"))

num_fr_or5<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper,fill=Condition), data=d_fr_num_agg_or) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,ncol =4)+
  labs(y = "S(sg)-S(pl)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))

ggsave("num_fr_or.pdf",width=5.06, height=1.8)

