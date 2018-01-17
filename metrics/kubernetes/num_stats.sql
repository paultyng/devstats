select
  'num_stats;All;companies,developers,unknowns' as name,
  count(distinct affs.company_name) as n_companies,
  count(distinct ev.actor_id) as n_authors,
  count(distinct ev.actor_id) filter (where affs.company_name is null) as n_unknown_authors
from
  gha_events ev
left join
  gha_actors_affiliations affs
on
  ev.actor_id = affs.actor_id
  and affs.dt_from <= ev.created_at
  and affs.dt_to > ev.created_at
where
  ev.created_at >= '{{from}}'
  and ev.created_at < '{{to}}'
  and ev.type in (
    'PullRequestReviewCommentEvent', 'PushEvent', 'PullRequestEvent',
    'IssuesEvent', 'IssueCommentEvent', 'CommitCommentEvent'
  )
union select sub.name,
  count(distinct sub.company_name) as n_companies,
  count(distinct sub.actor_id) as n_authors,
  count(distinct sub.actor_id) filter (where sub.company_name is null) as n_unknown_authors
from (
    select 'num_stats;' || coalesce(ecf.repo_group, r.repo_group) || ';companies,developers,unknowns' as name,
    affs.company_name,
    ev.actor_id
  from
    gha_repos r,
    gha_events ev
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = ev.id
  left join
    gha_actors_affiliations affs
  on
    ev.actor_id = affs.actor_id
    and affs.dt_from <= ev.created_at
    and affs.dt_to > ev.created_at
  where
    r.name = ev.dup_repo_name
    and ev.created_at >= '{{from}}'
    and ev.created_at < '{{to}}'
    and ev.type in (
      'PullRequestReviewCommentEvent', 'PushEvent', 'PullRequestEvent',
      'IssuesEvent', 'IssueCommentEvent', 'CommitCommentEvent'
      'PushEvent'
    )
  ) sub
where
  sub.name is not null
group by
  sub.name
order by
  n_companies desc,
  n_authors desc,
  name asc
;
