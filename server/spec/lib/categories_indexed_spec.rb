require 'spec_helper'

describe Categories do
  context 'with option ignore_unassigned_tokens' do
    context 'ignore_unassigned_tokens true' do
      before(:each) do
        @categories = described_class.new ignore_unassigned_tokens: true
      end
      it 'should return the right value' do
        @categories.ignore_unassigned_tokens.should == true
      end
    end
    context 'ignore_unassigned_tokens false' do
      before(:each) do
        @categories = described_class.new ignore_unassigned_tokens: false
      end
      it 'should return the right value' do
        @categories.ignore_unassigned_tokens.should == false
      end
    end
  end
  
  context "with real categories" do
    before(:each) do
      @index1 = Indexes::Memory.new :name, source: []
      
      @categories = described_class.new
      @categories << Category.new(:category1, @index1)
      @categories << Category.new(:category2, @index1)
      @categories << Category.new(:category3, @index1)
    end
    describe "similar_possible_for" do
      before(:each) do
        @token = Query::Token.processed 'similar~'
      end
      it "returns possible categories" do
        @categories.similar_possible_for(@token).should == []
      end
    end
  end
  
  describe 'clear_categories' do
    before(:each) do
      @categories = described_class.new
    end
    it 'is clear right at the beginning' do
      @categories.categories.should be_empty
      @categories.category_hash.should be_empty
    end
    it "isn't clear anymore after adding" do
      @categories << stub(:category, :name => :some_name)
      
      @categories.categories.should_not be_empty
      @categories.category_hash.should_not be_empty
    end
    it "is clear again after clearing" do
      @categories << stub(:category, :name => :some_name)
      
      @categories.clear_categories
      
      @categories.categories.should be_empty
      @categories.category_hash.should be_empty      
    end
  end
  
  context 'without options' do
    before(:each) do
      @index1 = Indexes::Memory.new :some_index, source: []
      
      @category1 = Category.new :category1, @index1
      @category2 = Category.new :category2, @index1
      @category3 = Category.new :category3, @index1
      
      @categories = described_class.new
      @categories << @category1
      @categories << @category2
      @categories << @category3
    end
    
    describe "possible_combinations" do
      before(:each) do
        @token = stub :token
      end
      context "with similar token" do
        before(:each) do
          @token.stub :similar? => true
        end
        it "calls the right method" do
          @categories.should_receive(:similar_possible_for).once.with @token
          
          @categories.possible_combinations @token
        end
      end
      context "with non-similar token" do
        before(:each) do
          @token.stub :similar? => false
        end
        it "calls the right method" do
          @categories.should_receive(:possible_for).once.with @token
          
          @categories.possible_combinations @token
        end
      end
    end
    
    describe 'possible_for' do
      context 'without preselected categories' do
        context 'user defined exists' do
          before(:each) do
            @token = stub :token, :user_defined_categories => [@category2]
          end
          context 'combination exists' do
            before(:each) do
              @combination = stub :combination
              @category2.stub! :combination_for => @combination
            end
            it 'should return the right combinations' do
              @categories.possible_for(@token).should == [@combination]
            end
          end
          context 'combination does not exist' do
            before(:each) do
              @category2.stub! :combination_for => nil
            end
            it 'should return the right combinations' do
              @categories.possible_for(@token).should == []
            end
          end
        end
        context 'user defined does not exist' do

        end
      end
      context 'with preselected categories' do

      end
    end

    describe 'possible_categories' do
      context 'user defined exists' do
        before(:each) do
          @token = stub :token, :user_defined_categories => [@category2]
        end
        it 'should return the right categories' do
          @categories.possible_categories(@token).should == [@category2]
        end
      end
      context 'user defined does not exist' do
        before(:each) do
          @token = stub :token, :user_defined_categories => nil
        end
        it 'should return all categories' do
          @categories.possible_categories(@token).should == [@category1, @category2, @category3]
        end
      end
    end

  end
  
end