# Simple example of toggling a model property via Ajax

We'll use an example of an article we can approve/un-approve.

# Model generation

rails g scaffold Article name:string approved:boolean

# Original article index view

<tr>
  <td><%= article.name %></td>
  <td><%= article.approved %></td>
  ...

Pull the approval info into a partial to keep changes localized.

<tr>
  <td><%= article.name %></td>
  <%= render :partial => 'approval' %>
  ...

# Approved/unapproved link text helper

Create helper method to encapsulate the display of approved/unapproved status. For this example we'll just use text.

def approve_link_text(approvable)
  approvable.approved? ? 'Un-approve' : 'Approve'
end

Two quick things to point out:

1) It's not tied to articles; it'll quack at anything with an "approved?" method.
2) I named the parameter something that should provide a hint to future devs.

# Add a resource method to toggle the approved status

## routes.db

resources :articles do
  get toggle_approve, :on => :member
end

## Article controller

(This isn't the final version yet.)

def toggle_approve
  @a = Article.find(params[:id])
  @a.toggle!(:approved)
  render :nothing => true
end

# Change the approval template

<td>
  <%= link_to approve_link_text(article), toggle_approve_article_path(article), :remote => true %>
</td>

Now if we refresh the page after clicking the link we'll see that the link text has changed. Approved articles will have an "Un-approve" link, un-approved articles an "Approve" link.

But refreshing is deeply unsatisfying.

# Dynamic feedback, Part 1

Remember when fadey-yellow things were cool? Yeah, we're all about that.

In order to affect change on our page, we'll need to add some markup to both the index template, so we can highlight the entire row, _and_ the approval helper, so we can change the link text.

## Articles index page

<% @articles.each do |article| %>
  <tr id="article_<%= article.id %>">
    <td><%= article.name %></td>
    <%= render :partial => 'approval', :locals => { :article => article } %>

Add an article-specific ID to each row.

## Approval helper

<td>
  <%= link_to approve_link_text(article), toggle_approve_article_path(article), :remote => true, :id => "approval_link_#{td.id}" %>
</td>

Add an article-specific ID to each approval link.

# Dynamic feedback, Part 2

Now that we can access the two DOM elements we care about, on a per-article basis, how do we actually make them change? By creating a JavaScript template and rendering it from the action. Just like we can render and return HTML, we can also render, return, _and_ execute JavaScript. This is handled transparently by Rails.

Note that some people don't like creating JavaScript this way. An alternative is to create DOM elements that our JavaScript can pull from. That's fine, but honestly, for simple things like this, I don't have a big problem with doing it the "old-fashioned way".

Our action is called "toggle_approve". We name JavaScript templates the same way we do ERb templates, so we'll create a toggle_approve.js.web just like we would if we had been returning HTML.

$("#approve_link_<%= @article.id %>").text("<%= approve_link_text(@article) %>");
$("#article_<%= @article.id %>").effect("highlight");

Line 1 sets the link text to Approve/Un-approve using the same helper we used in the HTML template.
Line 2 highlights the row we just updated.

That's it.
