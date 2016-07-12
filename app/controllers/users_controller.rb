class UsersController < ApplicationController
	require 'will_paginate/array'
skip_before_action :check_session, :only=>[:login,:validate_login]

    $pend_order = []

  def user_index 
    @user=User.all
    @user=User.new
    @user = User.find(session[:user_id]) 
  end

  def new
    @user=User.new
    @user = User.find(session[:user_id]).name 
  end
      
  def create
    @user=User.new(user_params)
    if @user.save
       flash[:notice] = "Successfully Registered!!!"
       redirect_to :action=> "new"
    else
       flash[:notice] = "Please fill in all of the required fields!!!"
       render "new"
    end
  end

  def user_destroy
    @user = User.find params[:id]
    @user.destroy
    flash[:notice] = "User Deleted Successfully!!!"
    redirect_to :action=>"new"
  end

  def login
    @user=User.new
  end

  def validate_login
    params.permit!
   @user=User.where params[:user]
  # @user= User.authenticate(params[:user][:name], params[:user][:password])
      if not @user.blank?
        session[:user_id]=@user.first.id
        redirect_to :action=>"dashboard"
      else
       #flash[:notice] = "Invalid Username or Password"
        redirect_to root_path,notice: "Invalid Username or Password!" and return
      end
  end

  def logout
    session[:user_id]=nil
	redirect_to root_path
  end

  
  def report_page
	@user=User.new
	@user = User.find(session[:user_id]).name
  end
	   
  def dashboard
	@user=User.new
	@user = User.find(session[:user_id]).name
    @lab = Labour.where('issue_date =?',Date.yesterday.strftime('%m/%d/%Y'))
    @mail = []
    @lab.each do |i|
      pr = ProductionReport.where(:id => i.production_report_id ).pluck(:id,:rejected_nos,:finished_goods_name,:weight_per_item,:total_weight_consumed,:rejected_nos_wt_for_re_grounding)
      pr << Issue.where(:id => i.issue_id).pluck(:chemicals,:rm_issues)
      pr = pr.flatten
      @l = Array.new << i.machine_no <<  i.shift << i.issue_date << pr[2] << pr[6] << pr[3] << i.mould << pr[7] << i.no_of_cavity << i.cycle_time << i.pro_time << i.expected_production << i.total_no_of_items_produced << pr[1]  << pr[5] << pr[4] << i.no_of_mins_idle << i.supervisor_name
      @mail << @l
    end
  end  

  def add_orderSummary
    @user=User.new
    @order_summary=OrderSummary.new
    @user = User.find(session[:user_id]).name
  end

  def get_order
    @order_summary=OrderSummary.new(order_summary_params)
    @order_summary.order_no = params[:order_summary][:order_no].to_i
    if @order_summary.save
      flash[:notice] = "Order Saved Successfully!!!"
      redirect_to :action => "index_orderSummary"
	else
	  flash.now[:notice] = "Order not Saved"
	  render "add_orderSummary"
	end
  end
	 
  def index_orderSummary
    @user = User.new
    @user = User.find(session[:user_id]).name
    if Date.today.month>=4
      @order_summary = OrderSummary.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
    else
      @order_summary = OrderSummary.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31"))
  	end

      $pend_order = @order_summary

     if params[:search]
     @order_summary = OrderSummary.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
     @order_summary =  @order_summary.search(params[:search]).paginate(page: params[:page]).per_page(10)
     render :action => :index_orderSummary
     end
	  @order_summary = @order_summary.paginate(page: params[:page]).per_page(10).order("order_no DESC")
  end
	  
  def show_orderSummary
    @user = User.new
    @user = User.find(session[:user_id]).name
    @order_summary = OrderSummary.find params[:id]
  end

  def edit_orderSummary
    @user = User.new
    @user = User.find(session[:user_id]).name
    @order_summary = OrderSummary.find params[:id]
  end

  def update_orderSummary
    @user = User.new
    @user = User.find(session[:user_id]).name
    @order_summary = OrderSummary.find params[:id]
    if @order_summary.update_attributes(order_summary_params)
       flash[:notice] = "Order Updated Successfully!!!"
       redirect_to :action=> "index_orderSummary"
    else
       render "edit_orderSummary"
    end
  end
	  
  def delete_orderSummary
    @pp = params[:id]
    @v = Issue.where(:order_summary_id => @pp).pluck(:id)
    @c = []
    @c << @v
    @kk1 = @c.flatten
    @v.each do  |i|
      if Labour.exists?(:issue_id => i) then
        Labour.find_by(:issue_id => i).destroy
      end
      if ProductionReport.exists?(:issue_id => i) then
        ProductionReport.find_by(:issue_id => i).destroy
      end
    end
    @v.map { |i| Issue.find(i).destroy }
    OrderSummary.find(@pp).destroy
    flash[:notice] = "Order Deleted Successfully!!!"
    redirect_to :action=>"index_orderSummary"
  end

  def report_order_summary
    @user=User.new
    @user = User.find(session[:user_id]).name
  end
      
  def order_summary_report
    $prpt={}
    @user=User.new
    @user = User.find(session[:user_id]).name
    $oss=params[:order_summary][:intial_date]
    $ose=params[:order_summary][:final_date]
    $osrt=params[:subject]
    $osfd,$oshd=[],[] 
    $osrt.map{|i| $osfd<<i.split("/")[0]}
    $osrt.map{|i| $oshd<<i.split("/")[1]}
    @order_summary=OrderSummary.where(:order_date=>$oss..$ose)#.select(@fl.join(","))
	#$prpt=@order_summary.where(:key => $prt)
    @order_summary1=OrderSummary.order_report_to_csv
    respond_to do |format|
    format.html
    format.csv { send_data @order_summary.order_summary_report_to_csv }
    format.xls { send_data @order_summary.order_summary_report_to_csv(col_sep: "\t") }
    end
  end

  def order_sum_report
    @order_summary=OrderSummary.where(:order_date => $oss..$ose)
    $ohd,$ofd=$oshd,$osfd
  end

  def index_orderSummayForIssue
    @user = User.new
    @user = User.find(session[:user_id]).name
    if Date.today.month>=4
      @order_summary = OrderSummary.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
	else
      @order_summary = OrderSummary.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31"))
	end
    if params[:search]
     @order_summary = OrderSummary.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
    @order_summary =  @order_summary.search(params[:search]).paginate(page: params[:page]).per_page(10)
     render :action => :index_orderSummayForIssue
     end
      @order_summary = @order_summary.paginate(page: params[:page], per_page: 10).order("order_no DESC")
  end


  def index_issuesForProduction
    @user = User.new
    @user = User.find(session[:user_id]).name
      if Date.today.month>=4
        @issue = Issue.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31")).order('issue_slip_no DESC')
	  else
        @issue = Issue.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31")).order('issue_slip_no DESC')
	  end
    #@issue = Issue.all
    @iss = []
    @issue.each do |i|
      unless ProductionReport.exists?(:issue_id=>i.id)
	    @iss << i
	  end
    end
     if params[:search]
     @issue = Issue.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31")).order("issue_slip_no DESC")
    @issue =@issue.search(params[:search]).paginate(page: params[:page]).per_page(10)
     render :action => :index_issuesForProduction
     end
    @issue = @iss.paginate(page: params[:page], per_page: 10)
  end


  def index_productionReport
    @user = User.new
    @user = User.find(session[:user_id]).name
    #@issue = Issue.all
      if Date.today.month>=4
        @issue = Issue.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
	  else
        @issue = Issue.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31"))
	  end
	  if Date.today.month>=4
	    @production_report = ProductionReport.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
	  else
        @production_report = ProductionReport.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31"))
	  end
          if params[:search]
     @production_report = ProductionReport.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
    @production_report =  @production_report.search(params[:search]).paginate(page: params[:page]).per_page(10)
     render :action => :index_productionReport
     end
	@production_report = @production_report.paginate(page: params[:page], per_page: 10).order("issue_slip_no DESC")
  end
	  
  def add_productionReport
    @user = User.new
    @issue = Issue.find(params[:id])
    @o_id = @issue.order_summary_id
    @order_summary = OrderSummary.where("id LIKE '%#{@o_id}%'")
    @cost = Cost.last
    @production_report = ProductionReport.new
    @user = User.find(session[:user_id]).name
  end

  def get_production
    @production_report = ProductionReport.new(production_report_params) 
      if @production_report.save
	    flash[:notice] = "Production Saved Successfully!!!"
        redirect_to :action => "index_productionReport"
      else
	    flash.now[:notice] = "Production not Saved"
	    render "add_productionReport"
	  end
  end

  def edit_productionReport
    @user = User.new
    @user = User.find(session[:user_id]).name
#   @issue = Issue.find(params[:id])
#   @production_report = ProductionReport.find_by ("issue_id LIKE '%#{params[:id]}%'")
    @production_report = ProductionReport.find params[:id]
    @i_id = @production_report.issue_id
    @issue = Issue.find_by("id LIKE '%#{@i_id}%'")
    @o_id = @issue.order_summary_id
    @order_summary = OrderSummary.find_by("id LIKE '%#{@o_id}%'")
    @cost = Cost.last
  end

  def update_productionReport
    @user = User.new
    @user = User.find(session[:user_id]).name
#   @production_report = ProductionReport.find_by ("issue_id LIKE '%#{params[:id]}%'")
    @production_report = ProductionReport.find params[:id]
      if @production_report.update_attributes(production_report_params)
        flash[:notice] = "Production Updated Successfully!!!"
        redirect_to :action=> "index_productionReport"
      else
        render "edit_productionReport"
      end
  end

  def show_productionReport
    @user = User.new
    @user = User.find(session[:user_id]).name
#   @issue = Issue.find(params[:id])
#   @production_report = ProductionReport.find_by ("issue_id LIKE '%#{params[:id]}%'")
    @production_report = ProductionReport.find params[:id]
    @i_id = @production_report.issue_id
    @issue = Issue.where("id LIKE '%#{@i_id}%'")
    @cost = Cost.last
  end

  def delete_productionReport
    pr = params[:id]
    if Labour.exists?(:production_report_id => pr) then
      Labour.find_by(:production_report_id => pr).destroy
    end
    if Finished.exists?(:production_report_id => pr) then
      Finished.find_by(:production_report_id => pr).destroy
    end
    ProductionReport.find(pr).destroy
#   @production_report = ProductionReport.find params[:id]
#   @production_report.destroy
    flash[:notice] = "Production Report Deleted Successfully!!!"
    redirect_to :action=>"index_productionReport"
  end

  def report_production
    @user=User.new
    @user = User.find(session[:user_id]).name
  end

  def productn_report
    @user=User.new
    @user = User.find(session[:user_id]).name
    $prs=params[:production_report][:intial_date]
    $pre=params[:production_report][:final_date]
    $prrt=params[:subject]
    $prfd,$prhd=[],[] 
    $prrt.map{|i| $prfd<<i.split("/")[0]}
    $prrt.map{|i| $prhd<<i.split("/")[1]}
    @iss=$prfd+Issue.column_names
    @prr=$prfd+ProductionReport.column_names
    @is=@iss.select{|i| @iss.count(i) > 1}
    @pr=@prr.select{|i| @prr.count(i) > 1}
    @issue = Issue.where(:issue_date => $prs..$pre)#.select((@is+["id"]).join(','))
    @production_report=ProductionReport.where(:date=>$prs..$pre)#@issue.select{|i| ProductionReport.where("id IS '#{i.id} AND date IS '#{$prs..$pre}'").select((@pr+["id","issue_id"]).join(','))}
    #ll=@production_report.pluck(:id)
   # @labour =Labour.where(:production_report_id =>ll).select(:cost_per_piece)
    @prod= @production_report + @issue #+@labour
    $prod=@prod
    @production_report1=ProductionReport.production_report_to_csv
    respond_to do |format|
	format.html
	format.csv { send_data @production_report.production_report_to_csv }
	format.xls { send_data @production_report.production_report_to_csv(col_sep: "\t") }
	end
  end

	  def product_report
	   @production_report=ProductionReport.where(:date => $prs..$pre)
	   $prod1=$prod
	  end

	   
	   def add_purchase
	     @user = User.new
	     @purchase = Purchase.new
	     @user = User.find(session[:user_id]).name
	   end

	   def get_purchase
	     @purchase = Purchase.new(purchase_params)
	     if @purchase.save
	       flash[:notice] = "Purchase Saved Successfully!!!"
	       redirect_to :action => "index_purchase"
	     else
	       flash.now[:notice] = "Purchase not Saved"
	       render "add_purchase"
	     end
	   end

	   def index_purchase
	     @user = User.new
	     @user = User.find(session[:user_id]).name
	     if Date.today.month>=4
	    @purchase = Purchase.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
		else
        @purchase = Purchase.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31"))
		end
              if params[:search]
     @purchase = Purchase.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
    @purchase =  @purchase.search(params[:search]).paginate(page: params[:page]).per_page(10)
     render :action => :index_purchase
     end
	     @purchase = @purchase.paginate(page: params[:page], per_page: 10).order("grn_no ASC")
	   end

	   def show_purchase
	     @user = User.new
	     @user = User.find(session[:user_id]).name
	     @purchase = Purchase.find params[:id]
	   end

	   def edit_purchase
	    @user = User.new
	    @user = User.find(session[:user_id]).name
	    @purchase = Purchase.find params[:id]
	  end

	  def update_purchase
	    @user = User.new
	    @user = User.find(session[:user_id]).name
	    @purchase = Purchase.find params[:id]
	    if @purchase.update_attributes(purchase_params)
	       flash[:notice] = "Purchase Updated Successfully!!!"
	       redirect_to :action=> "index_purchase"
	    else
	       render "edit_purchase"
	    end
	  end

	  def delete_purchase
	   @purchase = Purchase.find params[:id]
	   @purchase.destroy
	   flash[:notice] = "Purchase Deleted Successfully!!!"
	   redirect_to :action=>"index_purchase"
	  end

	  def report_purchase
           @user=User.new
           @user = User.find(session[:user_id]).name
          end

	   def purchase_report
	   @user=User.new
	   @user = User.find(session[:user_id]).name
	    $c=params[:purchase][:intial_date]
	    $d=params[:purchase][:final_date]
	    $prt=params[:subject]
           $prfd,$prhd=[],[] 
           $prt.map{|i| $prfd<<i.split("/")[0]}
           $prt.map{|i| $prhd<<i.split("/")[1]}
	    @purchase=Purchase.where(:date=>$c..$d)#.select(@fl.join(","))
	    #$prpt=@purchase.where(:key => $prt)
	      @purchase1=Purchase.purchase_report_to_csv
		respond_to do |format|
		 format.html
		 format.csv { send_data @purchase.purchase_report_to_csv }
		 format.xls { send_data @purchase.purchase_report_to_csv(col_sep: "\t") }
		end
	  end

	  def purchase_sum_report
	   @purchase=Purchase.where(:date => $c..$d)
	   $phd,$pfd=$prhd,$prfd
	  end

	  
	  def add_issues
	    @user = User.new
	    @issue = Issue.new
	    @order_summary = OrderSummary.find params[:id]
	    @user = User.find(session[:user_id]).name
	  end

	  def get_issues
	    @issue = Issue.new(issues_params)
	    if @issue.save
	      flash[:notice] = "Issues Saved Successfully!!!"
	      redirect_to :action => "index_issues"
	    else
	      flash.now[:notice] = "Issues not Saved"
	      render "add_issues"
	    end
	  end

	  def index_issues
	    @user = User.new
	    @user = User.find(session[:user_id]).name
	    if Date.today.month>=4
	    @issue = Issue.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
		else
        @issue = Issue.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31"))
		end
            if params[:search]
     @issue = Issue.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
     @issue =  @issue.search(params[:search]).paginate(page: params[:page]).per_page(10)
     render :action => :index_issues
     end
	    @issue = @issue.paginate(page: params[:page], per_page: 10).order("issue_slip_no DESC")
	  end

	  def show_issues
	    @user = User.new
	    @user = User.find(session[:user_id]).name
	    @issue = Issue.find params[:id]
	  end

	  def edit_issues
	    @user = User.new
	    @user = User.find(session[:user_id]).name
	    @issue = Issue.find params[:id]
	  end

	  def update_issues
	    @user = User.new
	    @user = User.find(session[:user_id]).name
	    @issue = Issue.find params[:id]
	    if @issue.update_attributes(issues_params)
	       flash[:notice] = "Issues Updated Successfully!!!"
	       redirect_to :action=> "index_issues"
	    else
	       render "edit_issues"
	    end
	  end

def delete_issues
  pp = params[:id]
  if Labour.exists?(:issue_id => pp) then
    Labour.find_by(:issue_id => pp).destroy
  end
  if ProductionReport.exists?(:issue_id => pp) then
    ProductionReport.find_by(:issue_id => pp).destroy
  end
          if Ireturn.exists?(:issue_id => pp) then
            Ireturn.find_by(:issue_id => pp).destroy
          end

  Issue.find(pp).destroy
#	    @issue = Issue.find params[:id]
#	    @issue.destroy
  flash[:notice] = "Issues Deleted Successfully!!!"
  redirect_to :action=>"index_issues"
end

	  def report_issues
           @user=User.new
           @user = User.find(session[:user_id]).name
      end

	   def issues_report
	   @user=User.new
	   @user = User.find(session[:user_id]).name
	    $iss=params[:issue][:intial_date]
	    $ise=params[:issue][:final_date]
	    $isrt=params[:subject]
           $isfd,$ishd=[],[] 
           $isrt.map{|i| $isfd<<i.split("/")[0]}
           $isrt.map{|i| $ishd<<i.split("/")[1]}
	    @issue=Issue.where(:issue_date=>$iss..$ise)#.select(@fl.join(","))
	    #$prpt=@issue.where(:key => $prt)
	      @issue1=Issue.issue_report_to_csv
		respond_to do |format|
		 format.html
		 format.csv { send_data @issue.issue_report_to_csv }
		 format.xls { send_data @issue.issue_report_to_csv(col_sep: "\t") }
		end
	  end

	  def issue_report
	   @issue=Issue.where(:issue_date => $iss..$ise)
	   $ihd,$ifd=$ishd,$isfd
	  end


          def add_labour
            @user = User.new
        #    @issue = Issue.find params[:id]
            @user = User.find(session[:user_id]).name
            @labour = Labour.new
            @production_report = ProductionReport.find params[:id]
            @i_id = @production_report.issue_id
            @issue = Issue.find_by ("id LIKE '%#{@i_id}%'")
            @o_id = @issue.order_summary_id
            @order_summary = OrderSummary.find_by ("id LIKE '%#{@o_id}%'")
            @j = MachineTime.where(:mo_no=>@order_summary.mould_no)
          end

          def get_labour
            @labour = Labour.new(labour_params)
            if @labour.save
              flash[:notice] = "Labour Saved Successfully!!!"
              redirect_to :action => "index_labour"
            else
              flash.now[:notice] = "Labour not Saved"
              render "add_labour"
            end
          end

    def index_productionForLabour
	    @user=User.new
	    @user = User.find(session[:user_id]).name
	    @production = []
	    if Date.today.month>=4
	    @production_report = ProductionReport.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31")).order('issue_slip_no DESC')
		else
        @production_report = ProductionReport.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31")).order('issue_slip_no DESC')
		end
	    #@production_report = ProductionReport.all
	    @production_report.each do |i|
        unless Labour.exists?(:production_report_id => i.id) 
        	@production << i
        end
    	end
 if params[:search]
      @production_report = ProductionReport.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
     @production_report = @production_report.search(params[:search]).paginate(page: params[:page]).per_page(10)
     render :action => :index_productionForLabour
     end

	    @production_report = @production.paginate(page: params[:page], per_page: 10)
	end

          def index_labour
            @user=User.new
            @user = User.find(session[:user_id]).name
            if Date.today.month>=4
	    	@labour = Labour.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
			else
        	@labour = Labour.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31"))
			end
               if params[:search]
     @labour = Labour.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
    @labour =  @labour.search(params[:search]).paginate(page: params[:page]).per_page(10)
     render :action => :index_labour
     end

#           @issue = Issue.all
#            @production_report = ProductionReport.all
            @labour = @labour.paginate(page: params[:page], per_page: 10).order("issue_slip_no DESC")
          end


          def show_labour
            @user=User.new
            @user = User.find(session[:user_id]).name
            @labour = Labour.find params[:id]
            @i_id = @labour.issue_id
            @issue = Issue.find_by ("id LIKE '%#{@i_id}%'")
#            @o_id = @issue.order_summary_id
#            @order_summary = OrderSummary.find_by("id LIKE '%#{@o_id}%'")
            @production_report = ProductionReport.find_by("issue_id LIKE '%#{@i_id}%'")
          end

          def edit_labour
            @user=User.new
            @user = User.find(session[:user_id]).name
            @labour = Labour.find params[:id]
            @i_id = @labour.issue_id
            @issue = Issue.find_by ("id LIKE '%#{@i_id}%'")
#            @o_id = @issue.order_summary_id
#            @order_summary = OrderSummary.find_by("id LIKE '%#{@o_id}%'")
            @production_report = ProductionReport.find_by("issue_id LIKE '%#{@i_id}%'")
          end


          def update_labour
            @user=User.new
            @user = User.find(session[:user_id]).name
            @labour = Labour.find_by ("production_report_id LIKE '%#{params[:id]}%'")
            if @labour.update_attributes(labour_params)
		       flash[:notice] = "Labour Updated Successfully!!!"
		       redirect_to :action=> "index_labour"
		    else
		       render "edit_labour"
		    end
		  end

		  def delete_labour
		    @labour = Labour.find params[:id]
		    @labour.destroy
		    flash[:notice] = "Labour Deleted Successfully!!!"
		    redirect_to :action=>"index_labour"
		  end


    def lab_report
      @user=User.new
      @user = User.find(session[:user_id]).name
    end

    def labour_report
      @user=User.new
      @user = User.find(session[:user_id]).name
    $lrsd=params[:labour][:intial_date]
    $lred=params[:labour][:final_date]
    $lrrt=params[:subject]
    $lrfd,$lrhd=[],[] 
    $lrrt.map{|i| $lrfd<<i.split("/")[0]}
    $lrrt.map{|i| $lrhd<<i.split("/")[1]}
    @liss=$lrfd+Labour.column_names
    @lrr=$lrfd+ProductionReport.column_names
    @is=@liss.select{|i| @liss.count(i) > 1}
    @lr=@lrr.select{|i| @lrr.count(i) > 1}
    @labourr = Labour.where(:issue_date => $lrsd..$lred)#.select((@is+["id"]).join(','))
    @prod_report=ProductionReport.where(:issue_date => $lrsd..$lred)#@issue.select{|i| ProductionReport.where("id IS '#{i.id} AND date IS '#{$prs..$pre}'").select((@pr+["id","issue_id"]).join(','))}
    @lrod=@labourr+@prod_report
    $lrod=@lrod
    @labour1=Labour.labour_to_csv
      respond_to do |format|
       format.html
       format.csv { send_data @labour.labour_to_csv }
       format.xls #{ send_data @production_report.production_report_to_csv(col_sep: "\t") }
      end
    end

    def report_labour
     @labourr=ProductionReport.where(:date => $lrsd..$lred)
     $lrod1=$lrod
    end


		  def machine_maintenance
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @machine_maintenance = MachineMaintenance.new
		  end

		  def get_machine
		   @machine_maintenance = MachineMaintenance.new(machine_maintenance_params)
		   if @machine_maintenance.save
		     flash[:notice] = "Machine Maintenance Saved"
		     redirect_to :action => "index_machineMaintenance"
		   else
		     flash[:notice] = "Machine Maintenance not Saved"
		     render "machine_maintenance"
		   end
		 end


		def index_machineMaintenance
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		   #@machine_maintenance = MachineMaintenance.all
		   if Date.today.month>=4
			@machine_maintenance = MachineMaintenance.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))
				else
			@machine_maintenance = MachineMaintenance.where(:created_at=>("#{Time.now.year-1}-04-01")..("#{Time.now.year}-03-31"))
				end
                    if params[:search]
                     @machine_maintenance = MachineMaintenance.where(:created_at=>("#{Time.now.year}-04-01")..("#{Time.now.year+1}-03-31"))   
                     @machine_maintenance=  @machine_maintenance.search(params[:search]).paginate(page: params[:page]).per_page(10)
                    render :action => :index_machineMaintenance
                    end

		   @machine_maintenance1 = @machine_maintenance.paginate(page: params[:page], per_page: 10).order("created_at DESC")
		 end

		 def edit_machine
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		   @machine_maintenance = MachineMaintenance.find params[:id]
		 end

		 def update_machine
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @machine_maintenance = MachineMaintenance.find params[:id]
		    if @machine_maintenance.update_attributes(machine_maintenance_params)
		     flash[:notice] = "Machine Maintenance Updated"
		     redirect_to :action => "index_machineMaintenance"
		   else
		     flash[:notice] = "Machine Maintenance not updated"
		     render "edit_machine"
		   end
		 end



		 def show_machine
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @machine_maintenance = MachineMaintenance.find params[:id]
		 end

		 def delete_machine
		   @machine_maintenance = MachineMaintenance.find params[:id]
		   if @machine_maintenance.destroy
		     flash[:notice] = "Machine Maintenance Deleted successfully"
		     redirect_to :action => "index_machineMaintenance"
		   else
		     flash[:notice] = "Machine Maintenance not deleted"
		     render "index_machineMaintenance"
		   end
		 end

		 def report_machine_maintenance
		   @user=User.new
		       @user = User.find(session[:user_id]).name 	
		 end

		 def machine_maintenance_report
			@user=User.new
				@user = User.find(session[:user_id]).name
			$mms=params[:machine_maintenance][:intial_date]
			$mme=params[:machine_maintenance][:final_date]
			$mno=params[:machine_maintenance][:mach_no]
			@machine_maintenance = MachineMaintenance.where(:date=>$mms..$mme)
			 end

		 def machine_maintenance_xls_report
			@machine_maintenance = MachineMaintenance.where(:date=>$mms..$mme)
		 end

		  def index_admin 
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @admin=Admin.new
		  end
		  
		  def admin_create
		    @admin=Admin.all
		  end

		  def purchase_type_new
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @purchase_type=TypeOfPurchase.new
		    ff=TypeOfPurchase.all
		   @purchase_type1 = ff.order('LOWER(purchase_type)').reverse
		   @purchase_type1=TypeOfPurchase.all.paginate(page: params[:page], per_page: 10).order("purchase_type ASC")
		  end

		  def purchase_type_create
		    @purchase_type = TypeOfPurchase.find_by(purchase_type_params)
		    if @purchase_type.present?
		      flash[:notice] = "Purchase Type Already Exists!!"
		      redirect_to :action => "purchase_type_new"
		    else
		      @purchase_type = TypeOfPurchase.new(purchase_type_params)
		      if @purchase_type.save
			flash[:notice] = "Purchase Type Saved Successfully!!"
			redirect_to :action => "purchase_type_new"
		      else
			flash[:notice] = "Purchase Type Already Exists"
			redirect_to :action => "purchase_type_new"
		      end
		    end
		  end

		  def purchase_type_delete
		   @purchase_type = TypeOfPurchase.find params[:id]
		   @purchase_type.delete
		   flash[:notice] = "Purchase Type Deleted Successfully!!!"
		   redirect_to :action=>"purchase_type_new"
		  end

		  def insert_material_new
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @insert_material=InsertMaterial.new
		    ff=InsertMaterial.all
		   @insert_material1 = ff.order('LOWER(insert_material_list)').reverse
		   @insert_material1=InsertMaterial.all.paginate(page: params[:page], per_page: 10).order(" insert_material_list ASC")
		  end

		  def insert_material_create
		    @insert_material = InsertMaterial.find_by(insert_material_params)
		    if @insert_material.present?
		      flash[:notice] = "Insert Material Type Already Exists!!"
		      redirect_to :action => "insert_material_new"
		    else
		      @insert_material = InsertMaterial.new(insert_material_params)
		      if @insert_material.save
			flash[:notice] = "Insert Material Type Saved Successfully!!"
			redirect_to :action => "insert_material_new"
		      else
			flash[:notice] = "Insert Material Type Already Exists"
			redirect_to :action => "insert_material_new"
		      end
		    end
		  end

		  def insert_material_delete
		   @insert_material = InsertMaterial.find params[:id]
		   @insert_material.delete
		   flash[:notice] = "Insert Material Type Deleted Successfully!!!"
		   redirect_to :action=>"insert_material_new"
		  end

		 
		  def chemical_type_new
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @chemical_type=ChemicalType.new
		    ff=ChemicalType.all
		   @chemical_type1 = ff.order('LOWER(chemical_type_list)').reverse
		   @chemical_type1=ChemicalType.all.paginate(page: params[:page], per_page: 10).order("chemical_type_list ASC")
		  end
		  
		  def chemical_type_create
		    @chemical_type = ChemicalType.find_by(chemical_type_params)
		    if @chemical_type.present?
		      flash[:notice] = "Chemical Type Already Exists!!"
		      redirect_to :action => "chemical_type_new"
		    else
		      @chemical_type = ChemicalType.new(chemical_type_params)
		      if @chemical_type.save
			flash[:notice] = "Chemical Type Saved Successfully!!"
			redirect_to :action => "chemical_type_new"
		      else
			flash[:notice] = "Chemical Type Already Exists"
			redirect_to :action => "chemical_type_new"
		      end
		    end
		  end
		 
		  def chemical_type_delete
		   @chemical_type = ChemicalType.find params[:id]
		   @chemical_type.delete
		   flash[:notice] = "Chemical Type Deleted Successfully!!!"
		   redirect_to :action=>"chemical_type_new"
		  end
		  
		 def party_order_new
		   @user=User.new
		    @user = User.find(session[:user_id]).name
		    @party_order=PartyOrder.new
		    ff=PartyOrder.all
		     @party_order1= ff.order('LOWER(party_order_list)')
		    if params[:search]
     @party_order1 =   @party_order1.search(params[:search]).paginate(page: params[:page]).per_page(10).order(" party_order_list ASC")
      else
      @party_order1= PartyOrder.paginate(page: params[:page], per_page: 10).order(" party_order_list  ASC")
       render :action => :party_order_new
   end
 
                  #@party_order1= PartyOrder.paginate(page: params[:page], per_page: 10).order("party_order_list ASC")
		 end
		  
		 def party_order_create
		    @party_order = PartyOrder.find_by(party_order_params)
		    if @party_order.present?
		       flash[:success] = "Party Already Exists"
		       redirect_to :action => "party_order_new"
		    else
		       @party_order  = PartyOrder.new(party_order_params)
		       if @party_order.save
			 flash[:success] = "Party Saved"
			 redirect_to :action => "party_order_new"
		       else
			 flash[:success] = "Party Already Exists"
			 redirect_to :action => "party_order_new"
		       end
		    end
		  end
		 
		  def party_order_delete
		    @party_order = PartyOrder.find params[:id]
		   @party_order.delete
		   flash[:notice] = "Party Order Deleted Successfully!!!"
		   redirect_to :action=>"party_order_new"
		  end
		  
		  def party_purchase_new 
		     @user=User.new
		    @user = User.find(session[:user_id]).name
		@party_purchase=PartyPurchase.new
		    ff=PartyPurchase.all
		    @party_purchase1 = ff.order('LOWER(party_purchase_list)')
                   if params[:search]
     @party_purchase1 =   @party_purchase1.search(params[:search]).paginate(page: params[:page]).per_page(10).order(" party_purchase_list ASC")
      else
      @party_purchase1= PartyPurchase.paginate(page: params[:page], per_page: 10).order(" party_purchase_list  ASC")
       render :action => :party_purchase_new
   end
		   #@party_purchase1 =PartyPurchase.paginate(page: params[:page], per_page: 10).order("party_purchase_list ASC")
		  end
		   
		   def party_purchse_create
		    @party_purchase = PartyPurchase.find_by(party_purchase_params)
		    if @party_purchase.present?
		       flash[:success] = "Party Already Exists"
		       redirect_to :action => "party_purchase_new"
		    else
		       @party_purchase  = PartyPurchase.new(party_purchase_params)
		       if @party_purchase.save
			 flash[:success] = "Party Saved"
			 redirect_to :action => "party_purchase_new"
		       else
			 flash[:success] = "Party Already Exists"
			 redirect_to :action => "party_purchase_new"
		       end
		    end
		  end

		   def party_purchse_delete
		    @party_purchase = PartyPurchase.find params[:id]
		   @party_purchase.delete
		   flash[:notice] = "Party Purchase Deleted Successfully!!!"
		   redirect_to :action=>"party_purchase_new"
		  end


		  def reground_new
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @reground=Reground.new
		     ff=Reground.all
		     @reground1 = ff.order('LOWER(reground_list)')
                   if params[:search]
     @reground1 =  @reground1.search(params[:search]).paginate(page: params[:page]).per_page(10).order("reground_list  ASC")
      else
      @reground1 = Reground.paginate(page: params[:page], per_page: 10).order("reground_list  ASC")
       render :action => :reground_new
   end
		  #@reground1 = Reground.paginate(page: params[:page], per_page: 10).order("reground_list ASC")
		  end

		  def reground_create
		    @reground = Reground.find_by(reground_params)
		    if @reground.present?
		       flash[:success] = "Reground Already Exists"
		       redirect_to :action => "reground_new"
		    else
		       @reground  = Reground.new(reground_params)
		       if @reground.save
			 flash[:success] = "Reground Saved"
			 redirect_to :action => "reground_new"
		       else
			 flash[:success] = "Reground Already Exists"
			 redirect_to :action => "reground_new"
		       end
		      end
		    end

		   def reground_delete
		    @reground = Reground.find params[:id]
		   @reground.delete
		   flash[:notice] = "Reground Deleted Successfully!!!"
		   redirect_to :action=>"reground_new"
		  end
		 


		  def chemical_new 
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @chemical=Chemical.new
		     ff=Chemical.all
		     @chemical1 = ff.order('LOWER(chemical_list)')
                     if params[:search]
             @chemical1 =  @chemical1.search(params[:search]).paginate(page: params[:page]).per_page(10).order(" chemical_list ASC")
              else
              @chemical1 = Chemical.paginate(page: params[:page], per_page: 10).order(" chemical_list ASC")
		  render :action => :chemical_new
		  end		  
#@chemical1 = Chemical.paginate(page: params[:page], per_page: 10).order(" chemical_list ASC")
		  end
		 
		  def chemical_create
		    @chemical = Chemical.find_by(chemical_params)
		    if @chemical.present?
		       flash[:success] = "Chemical Already Exists"
		       redirect_to :action => "chemical_new"
		    else
		       @chemical  = Chemical.new(chemical_params)
		       if @chemical.save
			 flash[:success] = "Chemical Saved"
			 redirect_to :action => "chemical_new"
		       else
			 flash[:success] = "Chemical Already Exists"
			 redirect_to :action => "chemical_new"
		       end
		      end
		    end

		   def chemical_delete
		    @chemical = Chemical.find params[:id]
		   @chemical.delete
		   flash[:notice] = "Chemical Deleted Successfully!!!"
		   redirect_to :action=>"chemical_new"
		  end

		    def raw_material_new 
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		   @raw_material=RawMaterial.new
		   ff=RawMaterial.all
		    @raw_material1=ff.order('LOWER(raw_material_list)')
                    if params[:search]
     @raw_material1 =  @raw_material1.search(params[:search]).paginate(page: params[:page]).per_page(10).order(" raw_material_list  ASC")
      else
      @raw_material1 =RawMaterial.paginate(page: params[:page], per_page: 10).order("raw_material_list  ASC")
       render :action => :raw_material_new 
   end
		    #@raw_material1 =RawMaterial.paginate(page: params[:page], per_page: 10).order("raw_material_list ASC")
		    end
		    
		   def raw_create
		   @raw_material = RawMaterial.find_by(ra_material_params)
		    if @raw_material.present?
		       flash[:success] = "Raw Material Already Exists"
		       redirect_to :action => "raw_material_new"
		    else
		       @raw_material  = RawMaterial.new(ra_material_params)
		       if @raw_material.save
			 flash[:success] = "Raw Material Saved"
			 redirect_to :action => "raw_material_new"
		       else
			 flash[:success] = "Raw Material Already Exists"
			 redirect_to :action => "raw_material_new"
		       end
		     end
		    end 
		 
		   def raw_delete
		    @raw_material = RawMaterial.find params[:id]
		   @raw_material.delete
		   flash[:notice] = "Raw Material Deleted Successfully!!!"
		   redirect_to :action=>"raw_material_new"
		  end
		  
	def rejection_reason_new 
		@user=User.new
		@user = User.find(session[:user_id]).name
		@rejection_reason=RejectionReason.new
		ff=RejectionReason.all
		@rejection_reason1=ff.order('LOWER(rejection_reason_list)')
                 if params[:search]
     @rejection_reason1 =  @rejection_reason1.search(params[:search]).paginate(page: params[:page]).per_page(10).order("rejection_reason_list  ASC")
      else
      @rejection_reason1 =RejectionReason.paginate(page: params[:page], per_page: 10).order("rejection_reason_list  ASC")
       render :action => :rejection_reason_new
   end
		#@rejection_reason1 =RejectionReason.paginate(page: params[:page], per_page: 10).order("rejection_reason_list ASC")
	end

	def rejection_reason_create
	  @rejection_reason = RejectionReason.find_by( rejection_reason_params)
	  if @rejection_reason.present?
		flash[:success] = "Rejection Reason Already Exists"
	    redirect_to :action => "rejection_reason_new"
	   else
		@rejection_reason  = RejectionReason.new( rejection_reason_params)
		if @rejection_reason.save
			flash[:success] = "Rejection Reason Saved"
			redirect_to :action => "rejection_reason_new"
		else
			flash[:success] = "Rejection Reason Already Exists"
		    redirect_to :action => "rejection_reason_new"
		end
	end
	end

	def rejection_reason_delete
	   @rejection_reason = RejectionReason.find params[:id]
	   @rejection_reason.delete
	   flash[:notice] = "Rejection Reason Deleted Successfully!!!"
	   redirect_to :action=>"rejection_reason_new"
	end


		  def reason_for_idle_new 
		 @user=User.new
		    @user = User.find(session[:user_id]).name
		     @reason_for_idle_time=ReasonForIdleTime.new
		    ff=ReasonForIdleTime.all
		    @reason_for_idle_time1=ff.order('LOWER(reason_for_idle_time_list)')
                if params[:search]
     @reason_for_idle_time1 =  @reason_for_idle_time1.search(params[:search]).paginate(page: params[:page]).per_page(10).order("reason_for_idle_time_list  ASC")
      else
      @reason_for_idle_time1 =ReasonForIdleTime.paginate(page: params[:page], per_page: 10).order("reason_for_idle_time_list  ASC")
       render :action => :reason_for_idle_new
   end		    
 #@reason_for_idle_time1 =ReasonForIdleTime.paginate(page: params[:page], per_page: 10).order("reason_for_idle_time_list ASC")
		  end

		   def reasonforidle_create
		     @reason_for_idle_time = ReasonForIdleTime.find_by( reasonidle_params)
		    if @reason_for_idle_time.present?
		       flash[:success] = "ReasonForIdleTime Already Exists"
		       redirect_to :action => "reason_for_idle_new"
		    else
			@reason_for_idle_time  = ReasonForIdleTime.new( reasonidle_params)
		       if @reason_for_idle_time.save
			 flash[:success] = "ReasonForIdleTime Saved"
			 redirect_to :action => "reason_for_idle_new"
		       else
			 flash[:success] = "ReasonForIdleTime Already Exists"
			 redirect_to :action => "reason_for_idle_new"
		       end
		    end
		  end
		   
		  def reasonforidle_delete
		    @reason_for_idle_time = ReasonForIdleTime.find params[:id]
		   @reason_for_idle_time.delete
		   flash[:notice] = "Reason For Idle Time Deleted Successfully!!!"
		   redirect_to :action=>"reason_for_idle_new"
		  end

		     def nature_new 
		   @user=User.new
		    @user = User.find(session[:user_id]).name
		   @nature_of_work=NatureOfWork.new
		   ff=NatureOfWork.all
		  @nature_of_work1=ff.order('LOWER(nature_of_work_list)')
		   if params[:search]
     @nature_of_work1 =   @nature_of_work1.search(params[:search]).paginate(page: params[:page]).per_page(10).order(" nature_of_work_list ASC")
      else
      @nature_of_work1 =NatureOfWork.paginate(page: params[:page], per_page: 10).order(" nature_of_work_list  ASC")
       render :action => :nature_new
   end
                    #@nature_of_work1 =NatureOfWork.paginate(page: params[:page], per_page: 10).order("nature_of_work_list ASC")
		   end   

		  def nature_create
		    @nature_of_work = NatureOfWork.find_by(nature_params)
		    if  @nature_of_work.present?
		       flash[:success] = "Nature Already Exists"
		       redirect_to :action => "nature_new"
		    else
			@nature_of_work  = NatureOfWork.new(nature_params)
		       if  @nature_of_work.save
			 flash[:success] = "Nature Saved"
			 redirect_to :action => "nature_new"
		       else
			 flash[:success] = "Nature Already Exists"
			 redirect_to :action => "nature_new"
		       end
		    end
		  end 

		 
		  def nature_delete
		    @nature_of_work = NatureOfWork.find params[:id]
		   @nature_of_work.delete
		   flash[:notice] = "Nature Of Work Deleted Successfully!!!"
		   redirect_to :action=>"nature_new"
		  end

		   
		   def goods_new
		 @user=User.new
		    @user = User.find(session[:user_id]).name
		     @finished_goods_name=FinishedGoodsName.new
		    ff=FinishedGoodsName.all
		   # @finished_goods_name1=FinishedGoodsName.order_by('finished_goods_name_list ASC').collect{|x|[x.finished_goods_name_list,x.id]}
		      @finished_goods_name1=ff.order('LOWER(finished_goods_name_list)')
                    if params[:search]
     @finished_goods_name1 =  @finished_goods_name1.search(params[:search]).paginate(page: params[:page]).per_page(10).order(" finished_goods_name_list ASC")
      else
      @finished_goods_name1 =FinishedGoodsName.paginate(page: params[:page], per_page: 10).order(" finished_goods_name_list ASC")
       render :action => :goods_new
   end
		    #@finished_goods_name1 =FinishedGoodsName.paginate(page: params[:page], per_page: 10).order("finished_goods_name_list ASC")  
		   end

		   def goods_create
		     @finished_goods_name = FinishedGoodsName.find_by(goods_params)
		    if @finished_goods_name.present?
		       flash[:success] = "Finished Goods Name Already Exists"
		       redirect_to :action => "goods_new"
		    else
			@finished_goods_name  = FinishedGoodsName.new(goods_params)
		       if @finished_goods_name.save
			 flash[:success] = "Finished Goods Name Saved"
			 redirect_to :action => "goods_new"
		       else
			 flash[:success] = "Finished Goods Name Already Exists"
			 redirect_to :action => "goods_new"
		       end
		    end
		  end


		  def goods_delete
		    @finished_goods_name = FinishedGoodsName.find params[:id]
		   @finished_goods_name.delete
		   flash[:notice] = "Finished Goods Name Deleted Successfully!!!"
		   redirect_to :action=>"goods_new"
		  end
		 
                   def machine_time
                    @user = User.find(session[:user_id]).name
                    @machine_time = MachineTime.new
                    @mach = MachineTime.all
                 end

                 def machine_time_create

                  @machine_time = MachineTime.find_by(machine_time_params)
                     if @machine_time.present?
                       flash[:success] = "Mould Already Exists"
                       redirect_to :action => "machine_time"
                    else
                        @machine_time  = MachineTime.new(machine_time_params)
                       if @machine_time.save
                         flash[:success] = "Mould Saved Successfully"
                         redirect_to :action => "machine_time"
                       else
                         flash[:success] = "Mould number Already Exists"
                         redirect_to :action => "machine_time"
                       end
                    end
                end 

                  def machine_time_delete
                    @machine_time= MachineTime.find params[:id]
                   @machine_time.delete
                   flash[:notice] = "Mould Deleted Successfully!!!"
                   redirect_to :action=>"machine_time"
                  end


                   def report_mould_hitory
                       @user=User.new
                       @user = User.find(session[:user_id]).name
                 end

                 def mould_history_report
                      @user=User.new
                      @user = User.find(session[:user_id]).name
                      $s=params[:mould_history][:intial_date]
                      $p=params[:mould_history][:final_date]
                      @t=params[:mould_history][:mould_no]
                      if @t!=""
                       @mould = Labour.where(:date=>$s..$p) && Labour.where(:mould=>@t)
                      else
                        @mould = Labour.where(:date=>$s..$p)
                      end
                 end

                  def mould_history_xls
                      if @t!=""
                       @mould = Labour.where(:date=>$s..$p) && Labour.where(:mould=>@t)
                      else
                        @mould = Labour.where(:date=>$s..$p)
                      end
                   end
 

		  def mach_use_new
		 @user=User.new
		    @user = User.find(session[:user_id]).name
		     @machine_used=MachineUsed.new
		    @machine_used1=MachineUsed.all
		  @machine_used1 =MachineUsed.paginate(page: params[:page], per_page: 10).order("created_at DESC")
		  end

		  def machine_use_create
		    @machine_used= MachineUsed.find_by(machine_use_params)
		    if  @machine_used.present?
		       flash[:success] = "Machine Used Already Exists"
		       redirect_to :action => "mach_use_new"
		    else
			@machine_used = MachineUsed.new(machine_use_params)
		       if  @machine_used.save
			 flash[:success] = "Machine Used Saved"
			 redirect_to :action => "mach_use_new"
		       else
			 flash[:success] = "Machine Used Already Exists"
			 redirect_to :action => "mach_use_new"
		       end
		    end
		  end

		 
		  def machine_use_delete
		   @machine_used = MachineUsed.find params[:id]
		   @machine_used.delete
		   flash[:notice] = "Machine Used Deleted Successfully!!!"
		   redirect_to :action=>"mach_use_new"
		  end

		  def mould_new
		 @user=User.new
		    @user = User.find(session[:user_id]).name
		   @mould_no=MouldNo.new
		   @mould_no1=MouldNo.all
                   if params[:search]
     @mould_no1 =  @mould_no1.search(params[:search]).paginate(page: params[:page]).per_page(10).order(" mould_no_list ASC")
      else
      @mould_no1 = MouldNo.paginate(page: params[:page], per_page: 10).order(" mould_no_list ASC")
       render :action => :mould_new
   end
		  #@mould_no1=MouldNo.paginate(page: params[:page], per_page: 40).order("mould_no_list ASC")

		  end

		  def mould_create
		    @mould_no= MouldNo.find_by(mould_params)
		    if  @mould_no.present?
		       flash[:success] = "MouldNo Already Exists"
		       redirect_to :action => "mould_new"
		    else
			@mould_no = MouldNo.new(mould_params)
		       if  @mould_no.save
			 flash[:success] = "MouldNo Saved"
			 redirect_to :action => "mould_new"
		       else
			 flash[:success] = "MouldNo Already Exists"
			 redirect_to :action => "mould_new"
		       end
		    end
		  end    
		 
		  def mould_delete
		    @mould_no =MouldNo.find params[:id]
		    @mould_no.delete
		    flash[:notice] = "Mould No Deleted Successfully!!!"
		    redirect_to :action=>"mould_new"
		  end
		  
		  def cost_new
		    @user = User.new
		    @user = User.find(session[:user_id]).name
		    @cost = Cost.new
		    @cost1 = Cost.last
		  end

		 def update_cost
		    @cost = Cost.new(cost_params)
		    Cost.last.delete
		    if @cost.save
		      flash[:notice] = "Cost Changed"
		      redirect_to :action => "cost_new"
		    else
		      flash[:notice] = "Cost not changed"
		      render "cost_new"
		    end
		  end



		def supervisor_name
		 @user=User.new
		    @user = User.find(session[:user_id]).name
		   @name_of_supervisor=NameOfSupervisor.new
		   @name_of_supervisor1=NameOfSupervisor.all
		  @name_of_supervisor1=NameOfSupervisor.paginate(page: params[:page], per_page: 10).order("created_at DESC")

		  end

		  def supervisor_create
		    @name_of_supervisor= NameOfSupervisor.find_by(supervisor_params)
		    if  @name_of_supervisor.present?
		       flash[:success] = "Supervisor Already Exists"
		       redirect_to :action => "supervisor_name"
		    else
			@name_of_supervisor = NameOfSupervisor.new(supervisor_params)
		       if  @name_of_supervisor.save
			 flash[:success] = "Supervisor Saved"
			 redirect_to :action => "supervisor_name"
		       else
			 flash[:success] = "Supervisor Already Exists"
			 redirect_to :action => "supervisor_name"
		       end
		    end
		  end

		  def supervisor_delete
		    @name_of_supervisor = NameOfSupervisor.find params[:id]
		    @name_of_supervisor.delete
		    flash[:notice] = "Supervisor Deleted Successfully!!!"
		    redirect_to :action=>"supervisor_name"
		  end



		  def yield_cost
	      @user = User.new
		  @user = User.find(session[:user_id]).name
		end

		def yield_cost_report
			@user=User.new
			@user = User.find(session[:user_id]).name
			@s_date = params[:labour][:intial_date]
			@e_date = params[:labour][:final_date]
			@i_id = Issue.where(:issue_date => @s_date..@e_date).pluck(:id)
			@arr = []
		@i_id.each do |i|
		    if ProductionReport.exists?(:issue_id=>i) && Labour.exists?(:issue_id=>i)
			pr = ProductionReport.where(:issue_id => i).pluck(:rejected_nos, :finished_goods_name, :weight_per_item, :total_weight_consumed)
			pr << Labour.where(:issue_id => i).pluck(:shift, :machine_no, :mould, :total_no_of_items_produced)
			pr << Issue.where(:id => i).pluck(:chemicals,:rm_issues,:rg_qty_return, :generated, :consolidated_qty, :consolidated_cost)
			pr = pr.flatten
			p = (pr[3].to_f != 0) ? ((pr[11].to_f/pr[3].to_f)*100).round(3)  : "--"
			pr << p
			q = (pr[12].to_f != 0) ? (pr[13].to_f/pr[12].to_f).round(3) : "--"
			pr << q
		    r = (pr[7].to_f != 0) ? (pr[13].to_f/pr[7].to_f).round(3) : "--"
		    pr << r
			@pr = Array.new << pr[4] << pr[5] << pr[1] << pr[6] << pr[9] << pr[8] << pr[2] << pr[7] << pr[0] << pr[10] << pr[11] << pr[14] << pr[15] << pr[16]
		    @arr << @pr
		    end
		end
	    end
		  
		   def yield_cost_report_xls
	      @issue = Issue.where(:issue_date => @s_date..@e_date)
	      end

		  
def report_oee
      @user = User.new
      @user = User.find(session[:user_id]).name
    end

    def oee_report
      @user = User.new
      @user = User.find(session[:user_id]).name
      @i_date = params[:production_report][:intial_date]
      @f_date = params[:production_report][:final_date]
      @lab = Labour.where(:issue_date => @i_date..@f_date).order(:issue_date).pluck(:id)
      @l = []
      @lab.each do |i|
        la = Labour.find_by(:id => i)
        pr = ProductionReport.find_by(:id => la.production_report_id )
        is = Issue.find_by(:id => la.issue_id)
        @ll = Array.new << la.machine_no << la.shift << la.issue_date << pr.finished_goods_name << is.chemicals << pr.weight_per_item << la.mould << is.rm_issues << la.no_of_cavity << la.cycle_time << la.pro_time << la.expected_production << la.total_no_of_items_produced << pr.rejected_nos << pr.rejected_nos_wt_for_re_grounding << pr.total_weight_consumed << la.no_of_mins_idle << la.supervisor_name
        @l << @ll
      end
    end


    def oee_xls_report
      @labour=Labour.where(:date => @i_date..@f_date)
    end

    def report_qty_after_rg
        @user=User.new
        @user = User.find(session[:user_id]).name
    end

  def qty_after_rg
      @user = User.new
      @user = User.find(session[:user_id]).name
      @m_date = params[:production_report][:intial_date]
      @v_date = params[:production_report][:final_date]
      @issu =Issue.where(:issue_date => @m_date..@v_date).order(:issue_date)
       @prod =@issu.pluck(:issue_date).uniq
       @qt = []
      @prod.each do |i|
       a=@issu.where(issue_date:i).pluck(:qty_after_rg)
       b=a.map{|k| "#{k}".to_f}.sum
          @pp = Array.new << i << b
           @qt << @pp
       end
       end


    def qty_after_rg_xls_report
       @production_report = ProductionReport.where(:date => $m..$v)
    end




		  def report_idle_time
		@user=User.new
		   @user = User.find(session[:user_id]).name
	      end

		  def idle_time_report
		   @user=User.new
	   @user = User.find(session[:user_id]).name
		    @bb=params[:labour][:intial_date]
		    @aa=params[:labour][:final_date]
		   @labour=Labour.where(:date => @bb..@aa)
		  @ss=[]
		  @labour.each do |i|
                unless i.no_of_mins_idle == "0.0000" or i.no_of_mins_idle == "0"
		  pr = i.production_report_id
		   if ProductionReport.exists?(:id=>pr)
		  @as= ProductionReport.where(:id => pr).pluck(:finished_goods_name)          
		 @pr1 = Array.new << i.shift,i.machine_no,i.mould,i.expected_production,i.total_no_of_items_produced,i.no_of_mins_idle,i.reasons_for_idle,i.supervisor_name,i.issue_date
		  @g =  @as + @pr1
		  @g1 = @g.flatten 
		  #@pr = Array.new 
		   @ss << [@g1[9]] + [@g1[1]]+[@g1[2]]+[ @g1[0]]+[ @g1[3]]+[@g1[4].to_f.round(3)]+[@g1[5]]+[@g1[6].to_i]+[@g1[7]]+[@g1[8]]
		  #@ss = Array.new << @pr 
		  end
		  end
		  end
                  end

		   def idle_time_report_xls
		      @labour=Labour.where(:date => @bb..@aa)
		   end   

		   def report_rejection_analysis
 		       @user=User.new
		       @user = User.find(session[:user_id]).name
		       end

		   def rejection_analysis  #RejectionAnalysis
		   @user=User.new
		   @user = User.find(session[:user_id]).name
		#  @production_report = ProductionReport.new
		   @i_date = params[:production_report][:intial_date]
		   @f_date = params[:production_report][:final_date]
		   @i_id = Issue.where(:issue_date => @i_date..@f_date).pluck(:id)
			   @arr = []
		   @i_id.each do |i|
		     if ProductionReport.exists?(:issue_id=>i) && Labour.exists?(:issue_id=>i) 	 
			pr = ProductionReport.where(:issue_id => i).pluck(:shift, :finished_goods_name, :rejected_nos, :reason_rejection, :total_weight_consumed,:rejected_nos_wt_for_re_grounding)
			pr << Labour.where(:issue_id => i).pluck(:no_of_cavity, :supervisor_name)
			pr << Issue.where(:id => i).pluck(:rm_issues,:generated)
			pr = pr.flatten
			re = (pr[4].to_f != 0) ? (((pr[5].to_f + pr[9].to_f)/pr[4].to_f) * 100).round(3) : "--"
		    pr << re
        pr << ProductionReport.where(:issue_id => i).pluck(:action_taken,:issue_date)
        pr = pr.flatten        
			@pr = Array.new << pr[0] << pr[1] << pr[8] << pr[6] << pr[2] << pr[10]<< pr[3] << pr[7] << pr[11] << pr[12]
			@arr << @pr
		     end
		end
	    end

	    def rejection_analysis_xls_report
	       @production_report = ProductionReport.where(:date => $ras..$rae)
	    end
	 



      
    def pending_order
      a = $pend_order.pluck(:order_no)
      a = a&a
      @pen = []
      a.each do |i|
        b = ProductionReport.where(:order_no => i).pluck(:total_no_of_items_produced)
        c = b.inject(0) { |sum, x| sum+x.to_i }
        d = OrderSummary.where(:order_no => i).pluck(:nos)
        e = d.inject(0) { |sum, x| sum+x.to_i}
        @n = i
        unless e <= c
          @f = e - c 
          @m = Array.new << @n,e,c,@f
          @pen << @m.flatten
        end
        @pend = @pen.sort
        end
      end


		 

		  def trash_orderSummary
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @order_summary = OrderSummary.only_deleted
		    @order_summary1 = OrderSummary.only_deleted.all.paginate(page: params[:page], per_page: 10).order("deleted_at DESC")
		  end

		  def trash_purchase
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @purchase = Purchase.only_deleted
		    @purchase1 = Purchase.only_deleted.all.paginate(page: params[:page], per_page: 10).order("deleted_at DESC")
		  end

		  def trash_issue
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @issue = Issue.only_deleted
		    @issue1 = Issue.only_deleted.all.paginate(page: params[:page], per_page: 10).order("deleted_at DESC")
		  end


		  def trash_labour
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @labour = Labour.only_deleted
		    @labour1 = Labour.only_deleted.all.paginate(page: params[:page], per_page: 10).order("deleted_at DESC")
		  end

		  def trash_production
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @production_report = ProductionReport.only_deleted
		    @production_report1 = ProductionReport.only_deleted.all.paginate(page: params[:page], per_page: 10).order("deleted_at DESC")
		  end


		  def trash_machine_maintenance
		    @user=User.new
		    @user = User.find(session[:user_id]).name
		    @machine_maintenance = MachineMaintenance.only_deleted
		    @machine_maintenance1 = MachineMaintenance.only_deleted.all.paginate(page: params[:page], per_page: 10).order("deleted_at DESC")
		  end

		  def trash_showPurchase
        @purchase = Purchase.only_deleted.find params[:id]
      end

      def trash_showOrderSummary
		    @order_summary = OrderSummary.only_deleted.find params[:id]
		  end

		  def trash_showIssue
        @issue = Issue.only_deleted.find params[:id]
		  end

		  def trash_showProduction
		    @production_report = ProductionReport.only_deleted.find params[:id]
        @i_id = @production_report.issue_id
        if Issue.only_deleted.exists?(:id => @i_id) then
          @issue = Issue.only_deleted.find_by("id LIKE '%#{@i_id}%'")
        else Issue.exists?(:id => @i_id)
          @issue = Issue.find_by("id LIKE '%#{@i_id}%'")                 
        end
          @cost = Cost.last
		  end

      def trash_showLabour
        @labour = Labour.only_deleted.find params[:id]
        @i_id = @labour.issue_id
        if Issue.only_deleted.exists?(:id => @i_id) then
        @issue = Issue.only_deleted.find_by ("id LIKE '%#{@i_id}%'")
      else Issue.exists?(:id => @i_id) 
        @issue = Issue.find_by("id LIKE '%#{@i_id}%'")
      end
      if ProductionReport.only_deleted.exists?(:issue_id => @i_id) then
        @production_report = ProductionReport.only_deleted.find_by("issue_id LIKE '%#{@i_id}%'")
      else ProductionReport.exists?(:issue_id => @i_id)
        @production_report = ProductionReport.find_by("issue_id LIKE '%#{@i_id}%'")
      end
    end

		  
      def trash_showMachineMaintenance
			  @machine_maintenance = MachineMaintenance.only_deleted.find params[:id]
		  end


		  def delete_trashOrderSummary
			  @pp = params[:id]
		    @v = Issue.only_deleted.where(:order_summary_id => @pp).pluck(:id)
		    @c = []
		    @c << @v
		    @kk1=@c.flatten
		    @v.each do  |i|
		    if Labour.only_deleted.exists?(:issue_id => i) then
		    Labour.only_deleted.find_by(:issue_id => i).really_destroy!
		    end
		    if ProductionReport.only_deleted.exists?(:issue_id => i) then
		    ProductionReport.only_deleted.find_by(:issue_id => i).really_destroy!
		    end
		  end
		    @v.map { |i| Issue.only_deleted.find(i).really_destroy! }
		    OrderSummary.only_deleted.find(@pp).really_destroy!
		    flash[:notice] = "Order Deleted Permanently!!!"
		    redirect_to :action=>"trash_orderSummary"
		  end

		  def delete_trashPurchase
		    @purchase = Purchase.only_deleted.find params[:id]
		    @purchase.really_destroy!
		    flash[:notice] = "Purchase Deleted Permanently!!!"
		    redirect_to :action=>"trash_purchase"
		  end

		  def delete_trashIssue
			pp = params[:id]
		  if Labour.only_deleted.exists?(:issue_id => pp) then
		    Labour.only_deleted.find_by(:issue_id => pp).really_destroy!
		  end
		  if ProductionReport.only_deleted.exists?(:issue_id => pp) then
		    ProductionReport.only_deleted.find_by(:issue_id => pp).really_destroy!
		  end
		  if Ireturn.only_deleted.exists?(:issue_id => pp) then
		    Ireturn.only_deleted.find_by(:issue_id => pp).really_destroy!
		  end
		  Issue.only_deleted.find(pp).really_destroy!
		 #   @issue = Issue.only_deleted.find params[:id]
		 #   @issue.really_destroy!
		    flash[:notice] = "Issue Deleted Permanently!!!"
		    redirect_to :action=>"trash_issue"
		  end

		  def delete_trashLabour
		    @labour = Labour.only_deleted.find params[:id]
		    @labour.really_destroy!
		    flash[:notice] = "Labour Deleted Permanently!!!"
		    redirect_to :action=>"trash_labour"
		  end


		  def delete_trashProduction
			pr = params[:id]
		       if Labour.only_deleted.exists?(:production_report_id => pr) then
		     Labour.only_deleted.find_by(:production_report_id => pr).really_destroy!
		   end
		   if Finished.only_deleted.exists?(:production_report_id => pr) then
		     Finished.only_deleted.find_by(:production_report_id => pr).really_destroy!
		   end
		   ProductionReport.only_deleted.find(pr).really_destroy!
		    # @production_report = ProductionReport.only_deleted.find params[:id]
		    # @production_report.really_destroy!
		    flash[:notice] = "Production Report Deleted Permanently!!!"
		    redirect_to :action=>"trash_production"
		  end


		  def delete_trashMachine
		    @machine_maintenance = MachineMaintenance.only_deleted.find params[:id]
		    @machine_maintenance.really_destroy!
		    flash[:notice] = "Machine Maintenance Deleted Permanently!!!"
		    redirect_to :action=>"trash_machine_maintenance"
		  end


      def restore_trashOrderSummary
        pp = params[:id]
        v = Issue.only_deleted.where(:order_summary_id => pp).pluck(:id)
        c = []
        c << v
        kk1 = c.flatten
        v.each do  |i|
        if Labour.only_deleted.exists?(:issue_id => i) then
        Labour.only_deleted.find_by(:issue_id => i).restore
        end
        if ProductionReport.only_deleted.exists?(:issue_id => i) then
        ProductionReport.only_deleted.find_by(:issue_id => i).restore
        end
      end
        v.map { |i| Issue.only_deleted.find(i).restore }
        OrderSummary.only_deleted.find(pp).restore
        flash[:notice] = "Order Restored Successfully!!!"
        redirect_to :action=>"trash_orderSummary"
      end

      def restore_trashPurchase
        @purchase = Purchase.only_deleted.find params[:id]
        @purchase.restore
        flash[:notice] = "Purchase Restored Successfully!!!"
        redirect_to :action=>"trash_purchase"
      end

      def restore_trashIssue
        pp = params[:id]
      if Labour.only_deleted.exists?(:issue_id => pp) then
        Labour.only_deleted.find_by(:issue_id => pp).restore
      end
      if ProductionReport.only_deleted.exists?(:issue_id => pp) then
        ProductionReport.only_deleted.find_by(:issue_id => pp).restore
      end
      Issue.only_deleted.find(pp).restore
        flash[:notice] = "Issue Restored Successfully!!!"
        redirect_to :action=>"trash_issue"
      end

      def restore_trashLabour
        @labour = Labour.only_deleted.find params[:id]
        @labour.restore
        flash[:notice] = "Labour Restored Successfully!!!"
        redirect_to :action=>"trash_labour"
      end


      def restore_trashProduction
        pr = params[:id]
           if Labour.only_deleted.exists?(:production_report_id => pr) then
         Labour.only_deleted.find_by(:production_report_id => pr).restore
       end
       ProductionReport.only_deleted.find(pr).restore
        flash[:notice] = "Production Report Restored Successfully!!!"
        redirect_to :action=>"trash_production"
      end

      def restore_trashMachine
        @machine_maintenance = MachineMaintenance.only_deleted.find params[:id]
        @machine_maintenance.restore
        flash[:notice] = "Machine Maintenance Restored Successfully!!!"
        redirect_to :action=>"trash_machine_maintenance"
      end




		  private
		  def user_params
		   params.require(:user).permit!
		  end

		  def purchase_params
		   params.require(:purchase).permit!
		  end
		  
		  def issues_params
		   params.require(:issue).permit!
		  end
		  
		  def labour_params
		   params.require(:labour).permit!
		  end
		  
		  def order_summary_params
		   params.require(:order_summary).permit!
		  end

		   def production_report_params
		      params.require(:production_report).permit!
		  end
		   def chemical_type_params
		     params.require(:chemical_type).permit!
		   end

		   def chemical_params
		     params.require(:chemical).permit!  
		   end

		   def party_order_params
		    params.require(:party_order).permit!
		   end 

		   def party_purchase_params
		    params.require(:party_purchase).permit!
		   end

		   def ra_material_params
		    params.require(:raw_material).permit!
	   end

	   def reasonidle_params
	      params.require(:reason_for_idle_time).permit!
	   end

	   def nature_params
	    params.require(:nature_of_work).permit!
	   end

	   def goods_params
	      params.require(:finished_goods_name).permit!
	   end

	   def mould_params
	     params.require(:mould_no).permit!
	   end

     def cost_params
       params.require(:cost).permit!
     end

        def machine_time_params
           params.require(:machine_time).permit!
           end


	   def machine_use_params
	    params.require(:machine_used).permit!
	   end

   
     def supervisor_params
      params.require(:name_of_supervisor).permit!
     end


    def purchase_type_params
      params.require(:type_of_purchase).permit!
  end

  def reground_params
    params.require(:reground).permit!
  end

  def insert_material_params
    params.require(:insert_material).permit!
  end

  def machine_maintenance_params
     params.require(:machine_maintenance).permit!
 end

 def rejection_reason_params
 	params.require(:rejection_reason).permit!
 end

  
end
