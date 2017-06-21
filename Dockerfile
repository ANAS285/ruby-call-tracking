FROM ruby:2.4-onbuild
EXPOSE 3000
CMD ["bundle exec puma -p 3000"]
