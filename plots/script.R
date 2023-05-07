library(ggplot2)

# set working dir to R src file
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# read in proposal data CSV, ensure address read in as string
raw <-
  read.csv('../proposal_data.csv',
           colClasses = c("proposer_address" = "character"))

# drop canceled props
p_data <- raw[raw$canceled == 'false', ]

# create df for prop success
prop_ids <- p_data$proposal_id
prop_passed <- rep(0, length(prop_ids))
prop_success_data <- data.frame(prop_ids, prop_passed)
# add 1 for successful prop ids
successful_props <-
  p_data[p_data$quorum_votes < p_data$for_votes, ]$proposal_id
prop_success_data[prop_success_data$prop_ids %in% successful_props, ] <-
  1


# Reshape data into long format
p_data_long <- tidyr::pivot_longer(
  p_data,
  cols = c(for_votes, against_votes, abstain_votes, uncast_votes),
  names_to = "vote_type",
  values_to = "vote_count"
)
# add prop success data to long df
# hack: setting defeated = 0.25, success = 0; points show on bottom in final plot
p_data_long$proposal_passed <- 0.25
p_data_long[p_data_long$proposal_id %in% successful_props, ]$proposal_passed <-
  0

colors <- c(
  "abstain_votes" = "#FECC00",
  "against_votes" = "#FF3B30",
  "for_votes" = "#34C759",
  "uncast_votes" = "#E5E5EA"
)
p_data_long$proposal_id <- as.factor(p_data_long$proposal_id)

# stacked bar
prop_vote_plot <-
  ggplot(p_data_long, aes(x = proposal_id, y = vote_count, fill = vote_type)) +
  geom_col() +
  labs(x = "Proposal", y = "Vote Count", fill = "Vote Type") +
  scale_x_discrete() + theme_bw() +
  scale_fill_manual(values = colors,
                    labels = c("abstain", "against", "for", "uncast")) +
  scale_y_continuous(
    limits = c(0, 700),
    breaks = c(200, 400, 600),
    labels = c(200, 400, 600)
  ) +
  theme(
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_text(size = 7, , color = "#AEAEB2"),
    axis.text.x = element_text(size = 4, vjust = 7),
    axis.text.y = element_text(size = 8),
    axis.title.y = element_text(size = 7, color = "#AEAEB2"),
    panel.background = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_blank(),
    legend.title = element_blank(),
    legend.key.size = unit(.4, 'cm'),
    #change legend key size
    legend.key.height = unit(.4, 'cm'),
    #change legend key height
    legend.key.width = unit(.4, 'cm'),
    #change legend key width
    legend.text = element_text(size = 5),
    text = element_text(family = "SF Mono")
  )


ggsave(
  'prop_vote_plot_mono.png',
  prop_vote_plot,
  dpi = 900,
  height = 3,
  width = 4,
  unit = 'in',
  bg = "white"
)


# stacked bar proportions
prop_vote_plot_p <- ggplot(p_data_long,
                           aes(x = proposal_id, y = vote_count, fill = vote_type)) +
  geom_point(
    x = p_data_long$proposal_id,
    y = p_data_long$proposal_passed,
    color = "#007aff",
    size = 1.5,
    alpha = 1,
    stroke = 0
  ) +
  geom_col(position = "fill") +
  labs(x = "Proposal", y = "Vote %", fill = "Vote Type") +
  scale_x_discrete() + theme_bw() +
  geom_hline(
    yintercept = 0.5,
    color = "#8e8e93",
    size = 0.25,
    alpha = 0.4
  ) +
  scale_fill_manual(values = colors,
                    labels = c("abstain", "against", "for", "uncast")) +
  scale_y_continuous(labels = c(25, 50, 75, 100),
                     breaks = c(.25, .5, .75, 1)) +
  theme(
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_text(size = 7, , color = "#AEAEB2"),
    axis.text.x = element_text(size = 4, vjust = 7),
    axis.text.y = element_text(size = 7),
    axis.title.y = element_text(size = 8, color = "#AEAEB2"),
    panel.background = element_blank(),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_blank(),
    legend.title = element_blank(),
    legend.key.size = unit(.4, 'cm'),
    #change legend key size
    legend.key.height = unit(.4, 'cm'),
    #change legend key height
    legend.key.width = unit(.4, 'cm'),
    #change legend key width
    legend.text = element_text(size = 5),
    text = element_text(family = "SF Mono")
  )


ggsave(
  'prop_vote_plot_mono_percentage.png',
  prop_vote_plot_p,
  dpi = 900,
  height = 3,
  width = 4,
  unit = 'in',
  bg = "white"
)
