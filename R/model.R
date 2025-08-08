# Load library.
suppressMessages(library(tidyverse))
library(splines)
library(pROC)

# Set seed.
set.seed(19171918)

# Read data.
train_1 <- read_csv('data/model/train_1.csv', show_col_types=FALSE) %>%
  mutate(across(c(type, hand, strength, team), as.factor))
test_1 <- read_csv('data/model/test_1.csv', show_col_types=FALSE) %>%
  mutate(across(c(type, hand, strength, team), as.factor))

# Model 1.1
# Train
model_1_1 <- glm(
  goal ~
    distance +
    angle +
    type +
    height +
    weight +
    hand +
    time +
    strength +
    dG +
    team,
  data=train_1,
  family=binomial()
)
# Test
summary(model_1_1)
# Predict
test_1$xG_1_1 <- predict(model_1_1, newdata=test_1, type='response')
# Evaluate
log_loss <- -mean(
  test_1$goal * log(test_1$xG_1_1) + (1-test_1$goal) * log(1-test_1$xG_1_1)
)
log_loss
roc_auc <- roc(test_1$goal, test_1$xG_1_1)$auc
roc_auc

# Model 1.2
model_1_2 <- glm(
  goal ~
    ns(distance, 4) +
    ns(angle, 4) +
    type +
    ns(time, 4) +
    strength +
    ns(dG, 4) +
    team +
    ns(distance, 4):ns(angle, 4),
  data=train_1,
  family=binomial()
)
# Test
summary(model_1_2)
# Predict
test_1$xG_1_2 <- predict(model_1_2, newdata=test_1, type='response')
# Evaluate
log_loss <- -mean(
  test_1$goal * log(test_1$xG_1_2) + (1-test_1$goal) * log(1-test_1$xG_1_2)
)
log_loss
roc_auc <- roc(test_1$goal, test_1$xG_1_2)$auc
roc_auc
