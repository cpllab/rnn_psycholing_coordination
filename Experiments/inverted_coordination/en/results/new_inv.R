rm(list = ls())
library(tidyverse)
library(lme4)
library(lmerTest)
library(stringr)
library(readxl)

library(patternplot)
library(ggplot2)

#####read results of Ethan
d_en_inv_items = read.csv('~/rnn-coord/inverted-en/items_num_inv.txt',sep="\t") 

d_en_inv_gulordava = read.csv('~/rnn-coord/inverted-en/surprisals-inv_number_en-gulordava.txt',sep="\t",header = FALSE) 
colnames(d_en_inv_gulordava)=c("model_word", "surprisal")
d_en_inv_gulordava$model= "gulordava"  
d_en_inv_res_gulordava=data.frame(d_en_inv_items,d_en_inv_gulordava)

d_en_inv_google = read.csv('~/rnn-coord/inverted-en/surprisals-inv_number_en-google.txt',sep="\t",header = FALSE) 
colnames(d_en_inv_google)=c("model_word","surprisal")
d_en_inv_google$model= "google"  
d_en_inv_res_google=data.frame(d_en_inv_items,d_en_inv_google)


###read results of RNNG action only

d_en_inv_RNNG_actiononly = read.csv('~/rnn-coord/inverted-en/surprisals-inv_number_en-actiononly.txt',sep="\t",header = FALSE) 
colnames(d_en_inv_RNNG_actiononly)=c("model_word","surprisal")
d_en_inv_RNNG_actiononly$model= "ActionLSTM"
d_en_inv_res_RNNG_actiononly=data.frame(d_en_inv_items,d_en_inv_RNNG_actiononly)

###read results of RNNG
d_en_inv_RNNG = read.csv('~/rnn-coord/inverted-en/surprisals-inv_number_en-rnng.txt',sep="\t",header = FALSE) 

colnames(d_en_inv_RNNG)=c("model_word","surprisal")
d_en_inv_RNNG$model= "RNNG"
d_en_inv_res_RNNG=data.frame(d_en_inv_items,d_en_inv_RNNG)

###read results of tiny
d_en_inv_tiny = read.csv('~/rnn-coord/inverted-en/surprisals-inv_number_en-tinylstm.txt',sep="\t",header = FALSE) 

colnames(d_en_inv_tiny)=c("model_word","surprisal")
d_en_inv_tiny$model= "LSTM (PTB)"
d_en_inv_res_tiny=data.frame(d_en_inv_items,d_en_inv_tiny)


####combine all results
d_en_inv_res=rbind(d_en_inv_res_google, d_en_inv_res_gulordava,d_en_inv_res_RNNG, d_en_inv_res_RNNG_actiononly,d_en_inv_res_tiny)

###37 items 

####remove items with UNK
d_en_inv_res= d_en_inv_res%>%group_by(sent_index)%>%
  filter(all(!(str_detect(model_word, "UNK"))))%>%
  ungroup()
###non UNK 37 items left










d_en_inv_res=rbind(d_en_inv_res_google, d_en_inv_res_gulordava,d_en_inv_res_RNNG, d_en_inv_res_RNNG_actiononly,d_en_inv_res_tiny)

### select columns and rename conditions
d_en_inv_res=d_en_inv_res%>%select(region, condition,surprisal,model,sent_index) %>%
  subset(region =="and"|region =="or" ) %>%
  separate(condition, sep="-", into=c("Verb","NP", "Conj" )) %>%
  unite("Condition", Verb, NP)

###aggregate results

std <- function(x) sd(x)/sqrt(length(x))
d_en_inv_res_agg = d_en_inv_res %>%
  group_by(Condition, Conj,model) %>%
  summarise(m=mean(surprisal),
            s= std(surprisal),
            upper=m + 1.96*s,
            lower=m - 1.96*s) %>%
  ungroup()



d_en_inv_res_agg= d_en_inv_res_agg %>%
  filter(Conj=="and")%>%
  filter(Condition=="Vpl_Npl"|Condition=="Vpl_Nsg"|Condition=="Vsg_Nsg")


d_en_inv_res_agg$Condition =factor(d_en_inv_res_agg$Condition, c("Vpl_Npl", "Vpl_Nsg", "Vsg_Nsg"))
#levels(d_en_inv_res_agg$Condition)=c("Vpl_Npl", "Vpl_Nsg","Vsg_Nsg")
d_en_inv_res_agg$model =factor(d_en_inv_res_agg$model,c("google","gulordava", "LSTM (PTB)","ActionLSTM", "RNNG" ))

levels(d_en_inv_res_agg$model)=c("LSTM (1B)","LSTM (enWiki)", "LSTM (PTB)","ActionLSTM", "RNNG")


###plotting
inv_en3<-ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, fill=Condition), data=d_en_inv_res_agg) +
  geom_bar(stat="identity", position="dodge", linetype="dashed") +
  geom_errorbar(color="black", width=.5, position=position_dodge(width=.9))+
  theme(axis.text.x = element_text(angle = 60, hjust = 1, vjust =1 ))+
  facet_wrap(~model,ncol = 5)+ 
  scale_fill_manual(values=c("#0066CC","#66CC00","#CC9933"))+
  labs(y = "Surprisal")+ 
  theme(axis.title.x=element_blank(),axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.direction='horizontal', 
        legend.position = "bottom",
        legend.justification = "center")

inv_en3

ggsave("inv_en_3.pdf",inv_en3, width=5.04, height=1.88)
inv_en3


plotting_df <-
  d_en_inv_res_agg%>% 
  # a trick!
#  mutate(m = if_else(Conj == "and", -m, m))%>%
#  mutate(upper = if_else(Conj == "and", -upper, upper))%>%
#  mutate(lower = if_else(Conj == "and", -lower, lower))%>%
  mutate(
    fill = paste(Conj, Condition, sep = "_"))






the_order <- plotting_df$Condition

plotting_df$fill=factor(plotting_df$fill, c('and_Vpl_Npl', 'and_Vpl_Nsg', 'and_Vsg_Npl','and_Vsg_Nsg','or_Vpl_Npl', 'or_Vpl_Nsg',  'or_Vsg_Npl','or_Vsg_Nsg'))
plotting_df$fill

inv_en2<- ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, group=Conj, fill=fill), data=plotting_df)+
  geom_bar(stat="identity", position="dodge", linetype="dashed", width =5) +
  geom_errorbar(color="black", width=1, position=position_dodge(width=5))+
  coord_flip() +
  scale_x_discrete(limits = the_order) +
  # another trick!
  scale_y_continuous(breaks = seq(-10, 10, 5), 
                     labels = abs(seq(-10, 10, 5))) +
  labs(x = element_blank(), y = "surprisal", title = "") +
  facet_wrap(~model,ncol = 5)+ 
  theme(legend.position = "right",
        legend.title = element_blank(),
        plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill =  "grey90")) +
        guides(fill=guide_legend(ncol=2, reverse = TRUE)) +
     #   guides(fill = guide_legend(reverse = TRUE), col = guide_legend(ncol = 2, byrow = TRUE)) +
  # change the default colors of bars
        scale_fill_manual(values=c( "pink","lightgoldenrod2","lightgreen","lightblue","#FF9999","#CC9933","#66CC00","#0066CC"),
                 #   name="",
               #     breaks=c('and','and','and','and','or','or','or','or'),
                    labels=c('and','and','and','and','or','or','or','or') )
  
inv_en2
ggsave("inv_en_2.pdf",inv_en2, width=6.04, height=2.38)

inv_en2_2<- ggplot(aes(x=Condition, y=m, ymin=lower, ymax=upper, group=Conj, fill=Conj), data=plotting_df)+
  geom_bar(stat="identity", position="dodge", linetype="dashed", width =5) +
  geom_errorbar(color="black", width=1, position=position_dodge(width=5))+
  coord_flip() +
  scale_x_discrete(limits = the_order) +
  # another trick!
  scale_y_continuous(breaks = seq(-10, 10, 5), 
                     labels = abs(seq(-10, 10, 5))) +
  labs(x = element_blank(), y = "surprisal", title = "") +
  facet_wrap(~model,ncol = 5)+ 
  theme(legend.position = "right",
        legend.title = element_blank(),
        plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill =  "grey90")) +
  guides(fill=guide_legend(ncol=1, reverse = TRUE)) +
  #   guides(fill = guide_legend(reverse = TRUE), col = guide_legend(ncol = 2, byrow = TRUE)) +
  # change the default colors of bars
  scale_fill_manual(values=c( "#66CC00","#0066CC"),
                    #   name="",
                    #     breaks=c('and','and','and','and','or','or','or','or'),
                    labels=c('and','or','and','and','or','or','or','or') )

inv_en2_2
ggsave("inv_en_2_2.pdf",inv_en2_2, width=6.04, height=2.38)





