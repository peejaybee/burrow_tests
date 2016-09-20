#To use

```bash
bundle install
bundle exec ruby event_consumer.rb
```
(in another window)
```bash
bundle exec ruby event_poster.rb
```
To do a POC for orchestration, comment and uncomment the proper lines in event_consumer, and in a third window, run
```bash
bundle exec ruby rpc_consumer.rb
```
then run the event poster in its window