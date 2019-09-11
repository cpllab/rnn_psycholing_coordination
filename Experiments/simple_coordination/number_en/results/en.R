rm(list = ls())
library(tidyr)
library(lme4)
library(lmerTest)
library(stringr)
library(readxl)


d_en_new = read.csv('~/rnn-coord/simple_num_en/items_simple.txt',sep="\t") 
d_en1 = read.csv('~/rnn-coord/simple_num_en/surprisals-simple_number_en-rnng.txt',sep="\t",header = FALSE) 
colnames(d_en1)=c("word1","surprisal")
d_en1$model= "RNNG"
d_en2 = read.csv('~/rnn-coord/simple_num_en/surprisals-simple_number_en-tinylstm.txt',sep="\t",header = FALSE) 
colnames(d_en2)=c("word1","surprisal")
d_en2$model="LSTM (PTB)"
d_en3 = read.csv('~/rnn-coord/simple_num_en/surprisals-simple_number_en-actiononly.txt',sep="\t",header = FALSE) 
colnames(d_en3)=c("word1","surprisal")
d_en3$model= "ActionLSTM"


#d_en4 = read.csv('~/dropbox/Exp/RNN/en/output_en_tf.txt',sep="\t",header = FALSE) 
#colnames(d_en4)=c("word1","surprisal")
#d_en4_new=subset(d_en4,word1!='-' & word1!='go')
#d_en4_new$model= "transfomer_XL"



d_en5 = read.csv('~/rnn-coord/simple_num_en/surprisals-simple_number_en-gulordava.txt',sep="\t",header = FALSE) 
colnames(d_en5)=c("word1","surprisal")
d_en5$model= "Gulordava"                      

d_en6 = read.csv('~/rnn-coord/simple_num_en/surprisals-simple_number_en-google.txt',sep="\t",header = FALSE) 
colnames(d_en6)=c("word1","surprisal")
d_en6$model= "Jozefowicz"                      


###
#d_en7 = read.csv('~/rnn-coord/simple_num_en/surprisals-simple_number_en-rnng_control.txt',sep="\t",header = FALSE) 
#colnames(d_en7)=c("word1","surprisal")
#d_en7$model= "RNNG-Control"  

#d_en8 = read.csv('~/rnn-coord/simple_num_en/surprisals-simple_number_en-rnng_coord.txt',sep="\t",header = FALSE) 
#colnames(d_en8)=c("word1","surprisal")
#d_en8$model= "RNNG-Coord"  



d1=data.frame(d_en_new,d_en1)
d2=data.frame(d_en_new,d_en2)
d3=data.frame(d_en_new,d_en3)


d5=data.frame(d_en_new,d_en5)
d6=data.frame(d_en_new,d_en6)
#d7=data.frame(d_en_new,d_en7)
#d8=data.frame(d_en_new,d_en8)


d_Aixiu=rbind(d1,d2,d3,d5,d6)
d_Aixiu=d_Aixiu%>% separate(condition, sep="-", into=c("Condition", "Verb")) %>%
          mutate(Verb = ifelse(Verb=="Vsg", "is","are"))%>%
          unite("condition", Condition, Verb)


d=d_Aixiu%>%group_by(sent_index)%>%
  filter(all(!(str_detect(word1, "UNK"))))%>%
  ungroup()


d=d%>%select(region, condition,surprisal,model,sent_index) %>%
  subset(region =="Vsg"|region =="Vpl"| region =="is"|region =="are") %>%
  separate(condition, sep="_", into=c("Conj", "N1","N2","Verb"))%>%
  unite("Condition", N1,Conj, N2)


d2= d%>%
  select(-region)%>%
  spread (Verb, surprisal )%>%
  mutate(diff=is-are)



length(d$surprisal)/37

std <- function(x) sd(x)/sqrt(length(x))
d_agg = d2%>%
  group_by(Condition, model) %>%
  summarise(m=mean(diff),
            s= std(diff),
            upper=m + 1.96*s,
            lower=m - 1.96*s) %>%
  ungroup()
View(d_agg)

d_agg$Condition=factor(d_agg$Condition,c("pl_and_pl","sg_and_pl","pl_and_sg","sg_and_sg","pl_or_pl","sg_or_pl","pl_or_sg","sg_or_sg"))

d_agg$model =factor(d_agg$model,c("Jozefowicz","Gulordava", "LSTM (PTB)","ActionLSTM", "RNNG"))
levels(d_agg$model)=c("LSTM (1B)","LSTM (enWiki)", "LSTM (PTB)","ActionLSTM", "RNNG")

d_en_and=subset(d_agg, Condition== "pl_and_pl" |Condition=="sg_and_pl"|Condition== "pl_and_sg"|Condition== "sg_and_sg")
d_en_agg_or=subset(d_agg, Condition== "pl_or_pl" |Condition=="sg_or_pl"|Condition== "pl_or_sg"|Condition== "sg_or_sg")


en_and=ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_en_and) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,nrow = 1, ncol = 7)+
  ylim(-4,15)+
  labs(y = "S(sg)-S(pl)")+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))
en_and

ggsave("en_and.pdf",width=5.06, height=1.8)

en_or1=ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_en_agg_or) +
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  facet_wrap(~model,nrow = 1, ncol = 7)+
  labs(y = "S(sg)-S(pl)")+
  ylim(-4,15)+
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")+
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933", "#FF9999"  ))
  
    en_or1

ggsave("en_or.pdf",width=5.06, height=1.8)


